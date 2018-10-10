import unittest

import priorityqueue

suite "priorityqueue":

  test "add, pop, count with eviction":
    var p = initPriQueue[int](maxSize = 3)

    check p.add(3) == PriFeedback[int](added: true, evicted: false)
    check p.add(2) == PriFeedback[int](added: true, evicted: false)
    check p.add(1) == PriFeedback[int](added: true, evicted: false)
    check p.count == 3

    check p.add(5) == PriFeedback[int](added: true, evicted: true, evictedElem: 1)
    check p.count == 3

    check p.add(4) == PriFeedback[int](added: true, evicted: true, evictedElem: 2)
    check p.count == 3

    check p.add(1) == PriFeedback[int](added: false, evicted: false)
    check p.count == 3