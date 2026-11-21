import Base

# Wire records use ~ for a newline. A code is either a proof body on its
# own, or machine|degree|proof|helper definitions. The latter form can
# express any package in the checker's pure source fragment.
def package(machine: String, degree: String, proof: String, helpers: String) -> String:
  helpers ++ "~def machine() -> M.Machine():~  " ++ machine ++
    "~def degree() -> Nat:~  " ++ degree ++
    "~def correct(+xs: M.Input()) -> {M.decide(machine(), degree(), xs) == M.partition(xs) : Bool}:~  " ++ proof

def expand(fields: +List<String>) -> String:
  match fields:
    case Con{m, Con{d, Con{p, Con{h, Nil{}}}}}: package(m, d, p, h)
    case Con{p, Nil{}}: package("[]", "0n", p, "")
    case _: ""

# A printable-ASCII odometer, least significant character first.
def increment(word: String) -> String:
  match word:
    case SNil{}: " "
    case SCon{'~', rest}: SCon{' ', increment(rest)}
    case SCon{Chr{n}, rest}: SCon{Chr{U32.add(n, 1)}, rest}

@unsafe
def enumerate(+word: String) -> IO(Unit):
  do IO<Unit>:
    IO.print(expand(String.split(word, '|')))
    enumerate(increment(word))

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(package("[]", "0n", "{==}", ""))
    IO.print(package("[M.Row{M.Answer{True{}}, M.Answer{True{}}, M.Answer{True{}}, M.Answer{True{}}}]", "0n", "{==}", ""))
    enumerate("")
