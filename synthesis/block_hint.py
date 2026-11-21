"""Recover exact partitions by splitting at integer scale boundaries."""
from itertools import accumulate
from math import gcd


def _balance_block(block, weights, limit):
    total = sum(weights[i] for i in block)
    if total % 2:
        return None
    target = total // 2
    chosen = []
    remaining = target
    for i in reversed(block):
        if weights[i] <= remaining:
            chosen.append(i)
            remaining -= weights[i]
    if remaining == 0:
        return chosen
    if len(block) > limit:
        return None
    for mask in range(1 << len(block)):
        subset = [index for bit, index in enumerate(block) if mask & (1 << bit)]
        if sum(weights[i] for i in subset) == target:
            return subset
    return None


def block_witness(weights):
    """Return selected input indices, or None if the decoder found no witness."""
    weights = tuple(weights)
    if any(w < 0 for w in weights):
        raise ValueError("expected nonnegative weights")
    order = sorted((i for i, w in enumerate(weights) if w), key=weights.__getitem__)
    suffix_gcd = list(accumulate((weights[i] for i in reversed(order)), gcd, initial=0))[::-1]
    length = sum(max(1, w.bit_length()) + 1 for w in weights)
    limit = 6 + (length + 2).bit_length() - 1
    first = 0
    block_sum = 0
    chosen = []
    for end, i in enumerate(order, start=1):
        block_sum += weights[i]
        if end < len(order) and block_sum >= suffix_gcd[end]:
            continue
        subset = _balance_block(order[first:end], weights, limit)
        if subset is None:
            return None
        chosen.extend(subset)
        block_sum = 0
        first = end
    return tuple(chosen)
