import unittest

import priorityqueue

suite "priorityqueue":

  test "add, pop, count":
    var p = initPriQueue[string]()

    p.add("Clear drains", 3)
    p.add("Feed cat", 4)
    p.add("Make tea", 5)
    p.add("Solve RC tasks", 1)
    p.add("Tax return", 2)

    check p.count == 5
    check p.pop == ("Solve RC tasks", 1.0)
    check p.pop == ("Tax return", 2.0)
    check p.pop == ("Clear drains", 3.0)
    check p.pop == ("Feed cat", 4.0)
    check p.pop == ("Make tea", 5.0)
    check p.count == 0
