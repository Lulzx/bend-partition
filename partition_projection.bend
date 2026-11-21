import Base

# The six weights total 40. The candidate partition target is 20.
def weights() -> List<Nat>:
  [2n, 3n, 4n, 9n, 10n, 12n]

# At scale p/q, round each scaled weight to the nearest integer.
# Keep all errors in units of 1/q. Ties can round either way.
type Summary is Data:
  Rounded{odd: Bool, total_error: Nat, largest_error: Nat}

def accumulate(qr: Nat & Nat, +q: Nat, tail: Summary) -> Summary:
  (whole, +rem) = qr
  Rounded{tail_odd, total, largest} = tail
  up = Nat.is_lt(q, Nat.add(rem, rem))
  odd = Bool.xor(Nat.is_eq(Nat.mod(whole, 2n), 1n), up)
  +err = Nat.min(rem, Nat.sub(q, rem))
  Rounded{Bool.xor(odd, tail_odd), Nat.add(err, total), Nat.max(err, largest)}

def summarize(xs: List<Nat>, +p: Nat, +q: Nat) -> Summary:
  match xs:
    case Nil{}: Rounded{False{}, 0n, 0n}
    case Con{x, rest}:
      accumulate(Nat.divmod(Nat.mul(x, p), q), q, summarize(rest, p, q))

# True iff the distance to every odd-sum integer vector is at least 1.
def outside(summary: Summary, q: Nat) -> Bool:
  match summary:
    case Rounded{odd, total, +largest}:
      match odd:
        case True{}: Nat.is_le(q, total)
        case False{}: Nat.is_le(Nat.add(largest, largest), total)

def misses_cut(p: Nat, +q: Nat) -> Bool:
  outside(summarize(weights(), p, q), q)

def endpoints(+p: Nat, +q: Nat) -> Bool:
  match p:
    case 0n: misses_cut(0n, q)
    case 1n+k: Bool.and(misses_cut(1n+k, q), endpoints(k, q))

# Check every j/(2*w) for j from 0 to 2*w, for each weight w.
def all_grids(xs: List<Nat>) -> Bool:
  match xs:
    case Nil{}: True{}
    case Con{+w, rest}:
      +q = Nat.add(w, w)
      Bool.and(endpoints(q, q), all_grids(rest))

def main() -> Bool:
  all_grids(weights())

# Numerator of the L1 error at scale p/q for a proposed rounded row.
def row_error(xs: List<Nat>, bs: List<Nat>, +p: Nat, +q: Nat) -> Nat:
  match xs bs:
    case Nil{} Nil{}: 0n
    case Con{x, rest} Con{b, tail}:
      +u = Nat.mul(p, x)
      +v = Nat.mul(q, b)
      err = Nat.sub(Nat.max(u, v), Nat.min(u, v))
      Nat.add(err, row_error(rest, tail, p, q))
    case _ _: Nat.add(q, q)

def first_row_error() -> {row_error(weights(), [1n,1n,1n,2n,2n,3n], 1n, 4n) == 6n : Nat}:
  {==}

def second_row_error() -> {row_error(weights(), [1n,1n,1n,4n,4n,5n], 5n, 12n) == 18n : Nat}:
  {==}
