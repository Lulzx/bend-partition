import Base

# Does a nonempty subset of the signed input sum to zero?
type Signed is Data:
  Plus{magnitude: Nat}
  Minus{magnitude: Nat}

# Keep exact totals on each side of the equality.
type Totals is Data:
  Sums{positive: Nat, negative: Nat}

def include_value(sums: Totals, value: Signed) -> Totals:
  match sums:
    case Sums{p, n}:
      match value:
        case Plus{x}: Sums{Nat.add(x, p), n}
        case Minus{x}: Sums{p, Nat.add(x, n)}

def accepts(sums: Totals, used: Bool) -> Bool:
  match sums:
    case Sums{p, n}: Bool.and(used, Nat.is_eq(p, n))

# One bit per input position. Reject masks of the wrong length.
def check_mask(xs: +List<Signed>, mask: List<Bool>, sums: Totals, used: Bool) -> Bool:
  match xs:
    case Nil{}:
      match mask:
        case Nil{}: accepts(sums, used)
        case Con{_, _}: False{}
    case Con{x, rest}:
      match mask:
        case Nil{}: False{}
        case Con{bit, bits}:
          match bit:
            case True{}: check_mask(rest, bits, include_value(sums, x), True{})
            case False{}: check_mask(rest, bits, sums, used)

def verify(xs: +List<Signed>, mask: List<Bool>) -> Bool:
  check_mask(xs, mask, Sums{0n, 0n}, False{})

# Each fork fixes the next bit. A leaf represents one complete mask.
def search(xs: +List<Signed>, +sums: Totals, used: Bool) -> Bool:
  match xs:
    case Nil{}: accepts(sums, used)
    case Con{x, +rest}:
      taken skipped = search(rest, include_value(sums, x), True{}) search(rest, sums, used)
      Bool.or(taken, skipped)

def subset_sum(xs: +List<Signed>) -> Bool:
  search(xs, Sums{0n, 0n}, False{})

def example() -> +List<Signed>:
  [Minus{7n}, Minus{3n}, Minus{2n}, Plus{5n}, Plus{8n}]

def example_witness() -> {verify(example(), [False{}, True{}, True{}, True{}, False{}]) == True{} : Bool}:
  {==}

def impossible_example() -> {subset_sum([Minus{7n}, Plus{3n}, Plus{5n}]) == False{} : Bool}:
  {==}

def empty_input() -> {subset_sum([]) == False{} : Bool}:
  {==}

def single_zero() -> {subset_sum([Plus{0n}]) == True{} : Bool}:
  {==}

def main() -> Bool:
  subset_sum(example())
