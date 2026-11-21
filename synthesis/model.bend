import Base

# A list of weights. Each weight is a most-significant-bit-first binary word.
def Input() -> Data:
  +List<+List<Bool>>

type Symbol is Data:
  Blank{}
  Bit0{}
  Bit1{}
  EndWeight{}

type Instruction is Data:
  Answer{answer: Bool}
  Left{write: Symbol, state: Nat}
  Right{write: Symbol, state: Nat}

type State is Data:
  Row{blank: Instruction, zero: Instruction, one: Instruction, end: Instruction}

def Machine() -> Data:
  +List<State>

def emit_bits(bits: +List<Bool>, tail: +List<Symbol>) -> +List<Symbol>:
  match bits:
    case Nil{}: EndWeight{} <> tail
    case Con{bit, rest}:
      Bool.pick(Symbol, bit, Bit1{}, Bit0{}) <> emit_bits(rest, tail)

def tape(xs: Input()) -> +List<Symbol>:
  match xs:
    case Nil{}: Nil{}
    case Con{bits, rest}: emit_bits(bits, tape(rest))

def select_instruction(row: State, symbol: Symbol) -> Instruction:
  match row:
    case Row{blank, zero, one, end}:
      match symbol:
        case Blank{}: blank
        case Bit0{}: zero
        case Bit1{}: one
        case EndWeight{}: end

def lookup(row: Maybe<&2, State>, symbol: Symbol) -> Instruction:
  match row:
    case None{}: Answer{False{}}
    case Some{entry}: select_instruction(entry, symbol)

type Config is Data:
  Stop{answer: Bool}
  Work{state: Nat, left: +List<Symbol>, right: +List<Symbol>}

def move_left(left: +List<Symbol>, right: +List<Symbol>, state: Nat) -> Config:
  match left:
    case Nil{}: Work{state, Nil{}, Blank{} <> right}
    case Con{x, rest}: Work{state, rest, x <> right}

def execute(op: Instruction, left: +List<Symbol>, rest: +List<Symbol>) -> Config:
  match op:
    case Answer{answer}: Stop{answer}
    case Left{x, state}: move_left(left, x <> rest, state)
    case Right{x, state}: Work{state, x <> left, rest}

def step(row: Maybe<&2, State>, left: +List<Symbol>, right: +List<Symbol>) -> Config:
  match right:
    case Nil{}: execute(lookup(row, Blank{}), left, Nil{})
    case Con{x, rest}: execute(lookup(row, x), left, rest)

def run(fuel: Nat, +machine: Machine(), config: Config) -> Bool:
  match fuel config:
    case _ Stop{answer}: answer
    case 0n Work{_, _, _}: False{}
    case 1n+n Work{state, left, right}:
      next = step(List.get(&2, State, machine, state), left, right)
      run(n, machine, next)

def decide(machine: Machine(), degree: Nat, xs: Input()) -> Bool:
  +word = tape(xs)
  length = List.length(&2, Symbol, word)
  run(Nat.pow(2n+length, degree), machine, Work{0n, Nil{}, word})

# Exponential oracle. Only the correctness proposition uses this code.
def decode(bits: +List<Bool>, acc: Nat) -> Nat:
  match bits:
    case Nil{}: acc
    case Con{bit, rest}:
      digit = Bool.pick(Nat, bit, 1n, 0n)
      decode(rest, Nat.add(digit, Nat.double(acc)))

def balance(xs: Input(), +left: Nat, +right: Nat) -> Bool:
  match xs:
    case Nil{}: Nat.is_eq(left, right)
    case Con{bits, +rest}:
      +w = decode(bits, 0n)
      Bool.or(balance(rest, Nat.add(w, left), right), balance(rest, left, Nat.add(w, right)))

def partition(xs: Input()) -> Bool:
  balance(xs, 0n, 0n)
