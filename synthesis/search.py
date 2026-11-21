"""Feed the Bend enumeration to BendTT. Only a checked solver goes to stdout."""
import argparse
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
IMPORTS = "import Base\nimport ./model.bend as M\n\n"
SOLVE = """
def solve(xs: M.Input()) -> Bool:
  M.decide(machine(), degree(), xs)
"""
OBLIGATION = """import Base
import ./model.bend as M
import ./candidate.bend as C

def certified(+xs: M.Input()) -> {M.decide(C.machine(), C.degree(), xs) == M.partition(xs) : Bool}:
  C.correct(xs)
"""
# The search can supply pure definitions. Imports and the final proposition
# come exclusively from the driver. No candidate is run as an executable.
CHARS = re.compile(r"[A-Za-z0-9_ .,:(){}\[\]+*<>=&%\-\n]*")
DEF = re.compile(r"def ([A-Za-z_][A-Za-z0-9_]*)\(")


def admissible(body):
    if not CHARS.fullmatch(body) or re.search(r"\b(import|law|IO)\b", body):
        return False
    names = set()
    for line in body.splitlines():
        if line.strip() and not line.startswith(" "):
            header = DEF.match(line)
            if not header or header[1] in names or header[1] in {"main", "solve"}:
                return False
            names.add(header[1])
    return {"machine", "degree", "correct"} <= names


def invoke(bend, file, flag, seconds=None):
    return subprocess.run(
        [bend, str(file), flag], cwd=file.parent, capture_output=True,
        text=True, errors="replace", timeout=seconds,
    )


def confirmed(result):
    return result.returncode == 0 and result.stdout.strip() == "ALL PROOFS CHECK"


def check(bend, work, body, seconds):
    if not admissible(body):
        return None
    source = IMPORTS + body.rstrip() + "\n" + SOLVE
    (work / "candidate.bend").write_text(source)
    obligation = work / "obligation.bend"
    try:
        if invoke(bend, obligation, "--check-only", seconds).returncode:
            return None
        verdict = invoke(bend, obligation, "--verdict", seconds)
    except subprocess.TimeoutExpired:
        return None
    if confirmed(verdict):
        return source
    if "infrastructure" in (verdict.stdout + verdict.stderr).lower():
        raise RuntimeError(verdict.stdout + verdict.stderr)
    return None


def search(args):
    bend = shutil.which(args.bend)
    if not bend:
        raise RuntimeError(f"Bend executable unavailable: {args.bend}")
    bend = str(Path(bend).resolve())
    with tempfile.TemporaryDirectory(prefix="partition-search-") as directory:
        work = Path(directory)
        model = work / "model.bend"
        shutil.copyfile(HERE / "model.bend", model)
        (work / "obligation.bend").write_text(OBLIGATION)
        ready = invoke(bend, model, "--verdict")
        if not confirmed(ready):
            raise RuntimeError("BendTT preflight failed\n" + ready.stdout + ready.stderr)
        if args.candidate:
            body = args.candidate.read_text()
            result = check(bend, work, body, 30 + len(body))
            if result:
                sys.stdout.write(result)
                return 0
            print("Candidate did not obtain a certificate.", file=sys.stderr)
            return 1

        proc = subprocess.Popen([bend, str(HERE / "enumerate.bend")], stdout=subprocess.PIPE)
        try:
            for count, record in enumerate(proc.stdout, start=1):
                body = record.decode("ascii").rstrip("\n").replace("~", "\n")
                # Appending spaces to the helper field repeats any candidate
                # with an arbitrarily large budget in the ideal enumeration.
                result = check(bend, work, body, 5 + len(body))
                if result:
                    sys.stdout.write(result)
                    return 0
                if args.limit is not None and count >= args.limit:
                    print(f"No certificate in {count} records.", file=sys.stderr)
                    return 1
            raise RuntimeError(f"Bend enumeration stopped (status {proc.wait()}).")
        finally:
            proc.terminate()
            proc.stdout.close()
            proc.wait()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--bend", default=os.environ.get("BEND", "bend"))
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--limit", type=int, help="stop after this many generated records")
    mode.add_argument("--candidate", type=Path, help="check a package body directly")
    args = parser.parse_args()
    if args.limit is not None and args.limit < 1:
        parser.error("--limit must be positive")
    try:
        sys.exit(search(args))
    except (OSError, RuntimeError) as error:
        sys.exit(str(error))
