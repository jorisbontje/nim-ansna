import random
import sequtils
import unittest

import permutation

suite "permutation":
  setup:
    var rnd = initRand(42)

  test "permutation and inverse permutation":
    const length = 16

    let perm = randomPermutation(rnd, length)
    let perm_inv = inversePermutation(perm)

    let input = toSeq(1..length)
    for i in 0..<length:
      check(perm[perm_inv[i]] == i)
      check(perm_inv[perm[i]] == i)
