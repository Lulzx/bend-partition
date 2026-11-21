import Base
import ./partition_projection.bend as P
import ./stalled_partition.bend as S

def weights(a) -> List<a, Nat>:
  [12n, 32n, 35n, 40n, 60n, 80n, 101n, 132n, 137n, 140n, 141n, 158n, 158n]

def even_numerator(d: S.Distances) -> Nat:
  match d:
    case S.Parities{even, _}: even

def nearest_even(p: Nat, +q: Nat) -> Nat:
  even_numerator(S.distances(P.summarize(weights(&1), p, q), q))

# Minimum numerator over scales 1/q through (k+1)/q.
def minimum_numerator(+k: Nat, +q: Nat) -> Nat:
  match k:
    case 0n: nearest_even(1n, q)
    case 1n+j:
      here = nearest_even(2n+j, q)
      Nat.min(here, minimum_numerator(j, q))

def check_table(rows: List<(Nat & Nat)>) -> Bool:
  match rows:
    case Nil{}: True{}
    case Con{(+q, expected), rest}:
      k = Nat.sub(Nat.div(q, 2n), 1n)
      actual = minimum_numerator(k, q)
      Bool.and(Nat.is_eq(actual, expected), check_table(rest))

def certificate() -> List<(Nat & Nat)>:
  [(12n,24n), (32n,64n), (35n,70n), (40n,80n), (60n,120n), (80n,160n),
           (101n,212n), (132n,264n), (137n,286n), (140n,280n), (141n,294n), (158n,316n)]

def main() -> Bool:
  Bool.and(check_table(certificate()), Bool.not(S.reachable(weights(&2), 613n)))
