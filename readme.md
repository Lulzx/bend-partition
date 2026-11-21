# An equal-partition solution in Bend

**Can the weights 2, 3, 4, 9, 10, and 12 be split into two groups of equal weight? No.** They total 40, and two short integer equations prove that no subset weighs 20. The proof uses all six weights without enumerating the 64 subsets.

The same inference rule stalls on another impossible instance involving only three distinct weights. The [counterexample](#counterexample-to-completeness) settles the completeness question for this rule.

The repository also contains a search for a general PARTITION solver. [How the search works and why a verified output would imply P = NP](#searching-for-a-polynomial-time-solver)

## Proof

Assign each weight a sign, $+1$ for the first group and $-1$ for the second. Write $a=(2,3,4,9,10,12)$ and let $s$ be the six signs. An equal partition would satisfy $a\cdot s=0$.

For any real scale $\alpha$ and integer row $b$, such a partition must satisfy

$$
|b\cdot s|=|(b-\alpha a)\cdot s|\leq\sum_i |b_i-\alpha a_i|.
$$

Both possible signs are odd, so $b\cdot s$ has the same parity as the sum of the entries of $b$. If that sum is even and the error on the right is strictly below 2, the only possible value of $b\cdot s$ is zero.

| Scale $\alpha$ | Integer row $b$ | Sum of entries | Total absolute error |
| --- | --- | ---: | ---: |
| $1/4$ | $(1,1,1,2,2,3)$ | 10 | $6/4$ |
| $5/12$ | $(1,1,1,4,4,5)$ | 16 | $18/12$ |

Each row therefore has dot product zero with $s$. Subtract the first equation from the second and divide by two. This gives

$$
s_4+s_5+s_6=0.
$$

The sum of three signs is odd. This contradiction rules out an equal partition.

## Why use two rows?

A single integer row with **odd** entry sum would settle the instance immediately if its total error were strictly below 1. Its dot product with $s$ would have to be an odd integer of absolute value less than 1. For these six weights, the smallest error attainable by that test is exactly 1, even when the scale ranges over all real numbers.

To verify the minimum, let $d(\alpha)$ be the distance in the sum-of-absolute-errors metric from $\alpha a$ to the nearest odd-sum integer row. Adding 1 to $\alpha$ translates the row by $a$, whose entries sum to 40, so $d$ has period 1. Between consecutive points of the form $j/(2a_i)$, each coordinate stays between adjacent half-integers. The distance to any fixed integer row is affine there. The minimum over odd-sum rows is consequently concave on each such interval and attains a minimum at an endpoint.

At an endpoint, round each coordinate to a nearest integer. Write $E$ for the total error and $M$ for the largest coordinate error. If the rounded row has odd sum, $d=E$. Otherwise the cheapest parity change changes the rounding by one unit in a coordinate with error $M$, giving $d=E+1-2M$. Bend checks $d\geq1$ at every endpoint using integer arithmetic. At $\alpha=0$ a unit vector attains distance 1.

## Counterexample to completeness

Take seven copies of 4, six copies of 18, and four copies of 33. Their total is 268. **There is no subset of weight 134, yet the initial span admits no independent even-sum integer row at distance strictly below 2.**

### No equal partition exists

Let $x,y,z$ count the selected copies of 4, 18, and 33. The equation $4x+18y+33z=134$ forces $z$ even. Its three possible values exhaust the problem.

| Copies of 33 | Required sum from 4s and 18s | Reason it is impossible |
| ---: | ---: | --- |
| 0 | 134 | All the 4s and 18s together weigh 136. The omitted weights would have to sum to 2. |
| 2 | 68 | Dividing by 2 gives $2x+9y=34$. The only possible even values of $y$ are 0 and 2, requiring 17 or 8 copies of 4. Only 7 are available. |
| 4 | 2 | The smallest remaining weight is 4. |

### No first inference exists

Write $a$ for the 17 weights, with a separate coordinate for each copy. The integer rows on the line through $a$ are exactly its integer multiples. Indeed, if $4\alpha$ and $33\alpha$ are integers then so is $\alpha=33\alpha-8(4\alpha)$. Every multiple has even entry sum because $a$ sums to 268.

It remains to rule out nearby independent rows. Translation by $a$ preserves parity and independence from $a$, so it suffices to consider $0\leq\alpha\leq1$. For each *fixed* integer row $b$, the function $\sum_i|b_i-\alpha a_i|$ is affine between consecutive grid points $j/w$, where $w$ is 4, 18, or 33. A distance strictly below a threshold anywhere on one of these intervals would also occur at an endpoint.

The table gives the exact minimum distances on the interior grid points. It includes **all** integer rows of the indicated parity. In particular, rows may assign different integers to different copies of the same weight.

| Grid denominator $w$ | Numerators tested | Minimum even-row distance | Minimum odd-row distance |
| ---: | --- | ---: | ---: |
| 4 | 1 through 3 | 2 | 2 |
| 18 | 1 through 17 | 2 | $13/9$ |
| 33 | 1 through 32 | 2 | $13/11$ |

To reproduce an entry, round every coordinate of $ja/w$ to a nearest integer. With total rounding error $E$ and largest coordinate error $M$, the nearest row of the same parity has distance $E$. For the opposite parity the distance is $E+1-2M$. The Bend check evaluates these quantities as integer numerators over $w$. [Counterexample check](./stalled_partition.bend)

At $\alpha=0$, an independent even-sum integer row is nonzero and has even integer norm, hence norm at least 2. At $\alpha=1$, subtract $a$ to get the same bound. Odd-sum rows have distance at least 1 at both endpoints. Together with the table and the affine-interval argument, this proves the bounds at **every real scale**. Scale zero attains the even-row bound because the row $(1,-1,0,\ldots,0)$ is independent and has norm 2.

The rule requires error *strictly* below 2 to infer an equation. At error 2, an even dot product can equal $2$ or $-2$. Consequently the rule cannot add its first independent row on this input. The direct odd-row test also fails at every scale.

## A 13-weight counterexample

The method also stalls for $(12,32,35,40,60,80,101,132,137,140,141,158,158)$. The total is 1226. Exhaustive subset reachability rules out the target 613. The identity $3\cdot12-35=1$ implies that every integer row on the line is an integer multiple of the weight vector, so every such row has even sum.

For a fixed independent even-sum row $b$, the distance to $\alpha a$ attains a minimum at a breakpoint $b_i/a_i$. Translating by an integer multiple of $a$ and reflecting through zero preserve parity, independence, and distance to the line. Thus every candidate minimum has a representative at $p/q$ with $q$ a weight and $0\le p\le\lfloor q/2\rfloor$.

At each positive scale, round $pa_i/q$ to a nearest integer $u_i$ and set $r_i=|pa_i-qu_i|$. The numerator of the minimum distance to any even-sum integer row is

$$
N(p,q)=\sum_i r_i+\left(\sum_i u_i\bmod 2\right)\left(q-2\max_i r_i\right).
$$

| Denominator $q$ | 12 | 32 | 35 | 40 | 60 | 80 | 101 | 132 | 137 | 140 | 141 | 158 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Minimum $N(p,q)$ over positive numerators | 24 | 64 | 70 | 80 | 120 | 160 | 212 | 264 | 286 | 280 | 294 | 316 |

Every entry is at least $2q$. At zero, each independent even-sum integer row has norm at least 2, and $e_1+e_2$ attains 2. The exact distance from the line to the nearest independent even-sum row is therefore **2**. The Bend verifier checks equality with each tabulated numerator and checks that 613 is unreachable. [13-weight certificate](./partition_613.bend)

## Consequence for P versus NP

Each inference is sound, and the six-weight proof shows that combining rows can certify impossibility. The 17-weight example disproves completeness. Even a perfect search for admissible rows would stop at rank one here. The bound of $n-1$ rank increases says how long a chain can be, while this instance shows that a chain need not exist. P versus NP remains open. [Clay Mathematics Institute](https://www.claymath.org/millennium/p-vs-np/)

## Run the checks

Run from the repository directory with Bend 2.0.40. Each command prints `True{}`. [Bend installation instructions](https://bend-lang.com/)

```sh
bend partition_projection.bend
bend stalled_partition.bend
bend partition_613.bend
bend subset_sum.bend
```

- [partition_projection.bend](./partition_projection.bend) checks the six-weight endpoint bounds. Its two typed row-error equalities verify the numerators 6 and 18.
- [stalled_partition.bend](./stalled_partition.bend) computes all six entries of the counterexample table and independently checks that 134 is unreachable. The argument above extends its finite grid checks to every real scale.
- [partition_613.bend](./partition_613.bend) checks the 13-weight counterexample using the same parity and reachability routines.
- [subset_sum.bend](./subset_sum.bend) runs a separate exhaustive subset-sum example. Its result is positive because $-3-2+5=0$.

## Searching for a polynomial-time solver

The search tries to find **one machine that answers correctly on every list of binary weights**. For example, `[1, 1, 2]` requires YES because `1 + 1 = 2`. The list `[1, 2]` requires NO because its total is odd. A machine that always says YES is fast and gets the first example right, but the second example rules it out.

```text
Bend generates a candidate
    machine M     a finite table of tape instructions
    exponent d    one fixed number for every input
    proof p       a proposed proof about M running under its clock
        |
        v
Python submits the candidate and a fixed claim to the checker:
    For every input x, clocked(M, d, x) = exact_partition(x).
        |
        +-- no verified proof --> try the next candidate
        |
        +-- BendTT verifies p --> emit solve(x) = clocked(M, d, x)
```

**The clock gives the time bound.** Write each weight in binary followed by a delimiter. For `[1, 1, 2]` the tape is `1|1|10|`, so its length $L$ is 7 symbols. If $d=2$, the machine gets at most $(7+2)^2=81$ transitions. On any input the bound is $(L+2)^d$. Exhausting the clock returns NO. Leading zeros and zero weights are allowed.

**The proof gives correctness.** The reference function assigns each weight to the left or right group and returns YES if any assignment balances the sums. BendTT checks a proof of agreement for an arbitrary input. This covers both YES and NO cases, including the possibility of a wrong NO caused by the clock. The emitted solver runs only the clocked machine. [Enumerator](./synthesis/enumerate.bend) · [Machine and specification](./synthesis/model.bend) · [Checker driver](./synthesis/search.py)

### Why a verified output would imply P = NP

Binary PARTITION is NP-complete. For every decision problem $A$ in NP, there is a polynomial-time translation that preserves the YES or NO answer:

```text
input x for A  -->  translate x into binary weights  -->  solve(weights)
                         polynomial time                 polynomial time
                                                             |
                                                             v
                                                   correct answer for A
```

The translation takes polynomial time, so its output also has polynomial length in the size of $x$. Running the verified solver on those weights keeps the entire computation polynomial in the original input length. This would put every problem in NP in P. The reverse inclusion already holds because any deterministic polynomial-time algorithm can verify a YES answer by running the algorithm itself. Together the two inclusions give $P=NP$.

The five-record smoke run found no verified solver. Discovery could take arbitrarily long. No guarantee is known that the search will ever emit the machine and proof needed for this argument.

### Running the search

Use Python 3 and Bend 2.0.40 with `lean` v4.34.0 on `PATH`, or set `BENDTT` to a compatible built kernel. From the repository root run

```sh
python3 synthesis/search.py
```

The program returns after its first verified solution. If one is emitted, save the module beside `synthesis/model.bend` so its relative import resolves. For a finite smoke run use `python3 synthesis/search.py --limit 5`. The five-record run exits with status 1, reports that it found no certificate on stderr, and leaves stdout empty. Use `--bend PATH` to select a particular Bend executable.

The enumeration includes candidates that always accept or always reject, then visits finite printable strings in increasing length. The four-field encoding is `machine expression|degree expression|proof body|helper definitions`, with `~` standing for a line break. The checker admits pure function definitions in a restricted ASCII fragment. `--candidate FILE` checks a hand-written package body defining `machine`, `degree`, and `correct` against the same obligation. The driver supplies the imports and the universal theorem. The enumeration loop is outside the proof kernel's trusted input.

**What would make the search succeed?** Under the soundness of the kernel and the stated model, a verified output would put binary PARTITION in P and hence prove P = NP. With sufficient resources, the enumerator reaches every finite package expressible in its encoding. Whitespace padding offers the same package with successively larger checking budgets. Eventual success requires an expressible proof the kernel accepts. The existence of such a proof is open. Exhaustive source enumeration is impractical even for short programs.

### Would P = NP make proof search fast?

There is a precise conditional theorem. Fix a deterministic checker. Give the search problem a budget $B$ in unary and ask whether a prefix extends to a package of at most $B$ bits that the checker accepts within $B$ steps. This is in NP because a verifier can guess the remaining bits and simulate the bounded check. If P = NP, a polynomial-time decider exists for that prefix question. With a padded encoding, choosing each successive bit takes at most one such query, so an entire accepted package can be recovered in time polynomial in $B$ whenever one exists. Bounding checker steps explicitly matters because proof normalization can take much longer than reading the proof. [Cornell notes on search versus decision](https://courses.cs.cornell.edu/cs6810/2021fa/lec3.pdf)

That implication assumes P = NP. It supplies neither a successful budget for PARTITION nor an unconditional polynomial-time algorithm for prefix extension. It also gives no polynomial bound for the particular exhaustive enumerator implemented here. For one fixed theorem, a successful search has one fixed running time. The polynomial bound needed for PARTITION must hold as the input weight lists grow.
