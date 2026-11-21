import Base
import ./partition_projection.bend as P

def weights(a) -> List<a, Nat>:
  [4n, 4n, 4n, 4n, 4n, 4n, 4n,
   18n, 18n, 18n, 18n, 18n, 18n,
   33n, 33n, 33n, 33n]

# Distances are numerators with common denominator q.
type Distances is Data:
  Parities{even: Nat, odd: Nat}

def assign_parities(odd: Bool, total: Nat, changed: Nat) -> Distances:
  match odd:
    case True{}: Parities{changed, total}
    case False{}: Parities{total, changed}

def distances(summary: P.Summary, q: Nat) -> Distances:
  match summary:
    case P.Rounded{odd, +total, +largest}:
      changed = Nat.add(total, Nat.sub(q, Nat.add(largest, largest)))
      assign_parities(odd, total, changed)

def minimum(left: Distances, right: Distances) -> Distances:
  match left right:
    case Parities{e, o} Parities{f, p}: Parities{Nat.min(e, f), Nat.min(o, p)}

# Check p/q for every numerator from 1 to k+1 inclusive.
def interior_minimum(+k: Nat, +q: Nat) -> Distances:
  match k:
    case 0n: distances(P.summarize(weights(&1), 1n, q), q)
    case 1n+j:
      here = distances(P.summarize(weights(&1), 2n+j, q), q)
      minimum(here, interior_minimum(j, q))

def matches_minimum(d: Distances, even: Nat, odd: Nat) -> Bool:
  match d:
    case Parities{e, o}: Bool.and(Nat.is_eq(e, even), Nat.is_eq(o, odd))

def check_grid(+q: Nat, even: Nat, odd: Nat) -> Bool:
  matches_minimum(interior_minimum(Nat.sub(q, 2n), q), even, odd)

# An independent decision check for this finite instance.
def reachable(xs: +List<Nat>, +target: Nat) -> Bool:
  match xs:
    case Nil{}: Nat.is_eq(target, 0n)
    case Con{+w, +rest}:
      take = Bool.and(Nat.is_le(w, target), reachable(rest, Nat.sub(target, w)))
      Bool.or(take, reachable(rest, target))

def main() -> Bool:
  fours = check_grid(4n, 8n, 8n)
  eighteens = check_grid(18n, 36n, 26n)
  grids = Bool.and(fours, Bool.and(eighteens, check_grid(33n, 66n, 39n)))
  Bool.and(grids, Bool.not(reachable(weights(&2), 134n)))
