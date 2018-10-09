import options
import unittest

import fifo

suite "fifo":

  test "add and maxSize":
    var fifo = initFIFO[int](maxSize = 3)
    fifo.add(1)
    fifo.add(2)
    fifo.add(3)
    check(len(fifo) == 3)
    fifo.add(4)
    check(len(fifo) == 3)

