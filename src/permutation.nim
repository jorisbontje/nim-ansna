import random

type
  Permutation* = seq[int]

proc randomPermutation*(r: var Rand, n: int): Permutation =
  result = newSeq[int](n)
  for i in 0..<n:
    result[i] = i
  shuffle(r, result)

proc inversePermutation*(perm: Permutation): Permutation =
  let n = perm.len
  result = newSeq[int](n)
  for i in 0..<n:
    result[perm[i]] = i
