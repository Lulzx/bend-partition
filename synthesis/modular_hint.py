"""Recover the first modular partition in descending weight order.

A modulus is a proposed hint. Only an exact sum certifies a partition.
"""
from itertools import accumulate


def modular_witness(weights, modulus):
    """Return selected input indices, or None if the modular target is unreachable."""
    weights = tuple(weights)
    if modulus < 1 or any(weight < 0 for weight in weights):
        raise ValueError("expected nonnegative weights and a positive modulus")
    total = sum(weights)
    if total % 2:
        return None

    order = sorted(range(len(weights)), key=weights.__getitem__, reverse=True)

    def add_weight(residues, index):
        return residues | {(r + weights[index]) % modulus for r in residues}

    # suffix[i] contains the residues attainable from order[i:] alone.
    suffix = list(accumulate(reversed(order), add_weight, initial={0}))[::-1]
    remaining = (total // 2) % modulus
    if remaining not in suffix[0]:
        return None
    selected = []
    for i, index in enumerate(order):
        if remaining not in suffix[i + 1]:
            selected.append(index)
            remaining = (remaining - weights[index]) % modulus
    return tuple(selected)


def exact_witness(weights, modulus):
    """Return a verified partition, or None if this hint did not find one."""
    weights = tuple(weights)
    selected = modular_witness(weights, modulus)
    if selected is not None and 2 * sum(weights[i] for i in selected) == sum(weights):
        return selected
    return None


def padded_instance(weights, k):
    """Preserve PARTITION and make every residue attainable up to modulus 2**(k+1)-1."""
    if k < 1:
        raise ValueError("expected k >= 1")
    powers = [1 << i for i in range(k)]
    scale = 1 << (k + 1)
    return [scale * w for w in weights] + powers + [sum(powers)]
