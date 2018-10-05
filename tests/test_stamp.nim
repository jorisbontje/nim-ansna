import sequtils
import unittest

import stamp

proc toEvidentalBase(expected: openarray[int]): array[STAMP_size, int] =
  assert len(expected) <= STAMP_size
  for i, value in expected.pairs:
    result[i] = value
  for i in len(expected)..<STAMP_size:
    result[i] = STAMP_free

suite "stamp":

  setup:
    var a = Stamp()
    var b = Stamp()

  test "checkOverlap returns false when both empty":
    check(not checkOverlap(a, b))

  test "checkOverlap returns true for identical stamps":
    a.evidentalBase = [1].toEvidentalBase
    b.evidentalBase = [1].toEvidentalBase
    check(checkOverlap(a, b))

  test "checkOverlap returns false when no overlap":
    a.evidentalBase = [1].toEvidentalBase
    b.evidentalBase = [2].toEvidentalBase
    check(not checkOverlap(a, b))

  test "checkOverlap returns true for when overlaps":
    a.evidentalBase = [1].toEvidentalBase
    b.evidentalBase = [2, 1].toEvidentalBase
    check(checkOverlap(a, b))

  test "make empty stamps":
    let c = make(a, b)
    check(c.evidentalBase == [].toEvidentalBase)

  test "make identical stamps":
    a.evidentalBase = [1].toEvidentalBase
    b.evidentalBase = [1].toEvidentalBase
    let c = make(a, b)
    check(c.evidentalBase == [1, 1].toEvidentalBase)
    # ??? Shouldn't this be [1]
    # XXX https://github.com/patham9/ANSNA/issues/21

  test "make unequal stamps":
    a.evidentalBase = [1].toEvidentalBase
    b.evidentalBase = [2].toEvidentalBase
    let c = make(a, b)
    check(c.evidentalBase == [1, 2].toEvidentalBase)

  test "make b stamps longer":
    a.evidentalBase = [1].toEvidentalBase
    b.evidentalBase = [2, 3].toEvidentalBase
    let c = make(a, b)
    check(c.evidentalBase == [1, 2, 3].toEvidentalBase)

  test "make a stamps longer":
    a.evidentalBase = [1, 2].toEvidentalBase
    b.evidentalBase = [3].toEvidentalBase
    let c = make(a, b)
    check(c.evidentalBase == [1, 3, 2].toEvidentalBase)

  test "make a and b stamps longer":
    a.evidentalBase = [1, 2].toEvidentalBase
    b.evidentalBase = [3, 4].toEvidentalBase
    let c = make(a, b)
    check(c.evidentalBase == [1, 3, 2, 4].toEvidentalBase)

  test "make stamps truncation":
      a.evidentalBase = toSeq(1..20).toEvidentalBase
      b.evidentalBase = toSeq(40..59).toEvidentalBase
      let c = make(a, b)
      check(c.evidentalBase == [1, 40, 2, 41, 3, 42, 4, 43, 5, 44, 6, 45, 7, 46, 8, 47, 9, 48, 10, 49].toEvidentalBase)
