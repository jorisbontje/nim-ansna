import unittest

import minmaxheap

type PriElemInt = tuple[data: string, pri: int]

func `<`(a, b: PriElemInt): bool =
  result = a.pri < b.pri

type PriElemFloat = tuple[data: string, pri: float]

func `<`(a, b: PriElemFloat): bool =
  result = a.pri < b.pri

suite "minmaxheap":

  test "push, count, min, max, popMin, popMax":
    var p = initMinMaxHeap[int]()

    p.push(3)
    p.push(2)
    p.push(1)
    p.push(5)
    p.push(4)

    check p.max == 5
    check p.min == 1
    check p.count == 5

    check p.popMax == 5
    check p.popMin == 1
    check p.count == 3

    check p.popMax == 4
    check p.popMin == 2
    check p.count == 1

    check p.max == 3
    check p.min == 3

    check p.popMax == 3
    check p.count == 0

  test "push, popMin":

    var p = initMinMaxHeap[PriElemInt]()

    p.push(("Solve RC tasks", 5))
    p.push(("Clear drains", 3))
    p.push(("Feed cat", 2))
    p.push(("Make tea", 1))
    p.push(("Tax return", 4))

    check p.min == ("Make tea", 1)
    check p.popMin == ("Make tea", 1)
    check p.popMin == ("Feed cat", 2)
    check p.popMin == ("Clear drains", 3)
    check p.popMin == ("Tax return", 4)
    check p.popMin == ("Solve RC tasks", 5)

  test "push, popMin":

    var p = initMinMaxHeap[PriElemFloat]()

    p.push(("Solve RC tasks", 5.0))
    p.push(("Clear drains", 3.0))
    p.push(("Feed cat", 2.0))
    p.push(("Make tea", 1.0))
    p.push(("Tax return", 4.0))

    check p.min == ("Make tea", 1.0)
    check p.popMin == ("Make tea", 1.0)
    check p.popMin == ("Feed cat", 2.0)
    check p.popMin == ("Clear drains", 3.0)
    check p.popMin == ("Tax return", 4.0)
    check p.popMin == ("Solve RC tasks", 5.0)

  test "replace":

    var p = initMinMaxHeap[PriElemInt]()

    p.push(("Solve RC tasks", 5))
    p.push(("Clear drains", 3))
    p.push(("Feed cat", 2))
    p.push(("Make tea", 1))
    p.push(("Tax return", 4))

    # (buf: @[
    #  (data: "Make tea", pri: 1),
    #  (data: "Solve RC tasks", pri: 5),
    #  (data: "Clear drains", pri: 3),
    #  (data: "Feed cat", pri: 2),
    #  (data: "Tax return", pri: 4)])
    # echo p

    p.replace(4, ("XXX", 0))

    check p.popMin == ("XXX", 0)
    check p.popMin == ("Make tea", 1)
    check p.popMin == ("Feed cat", 2)
    check p.popMin == ("Clear drains", 3)
    # check p.popMin == ("Tax return", 4)
    check p.popMin == ("Solve RC tasks", 5)
