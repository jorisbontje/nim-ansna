import unittest

import event
import fifo

suite "fifo":

  test "add and maxSize":
    var fifo = initFIFO(maxSize = 3)
    fifo.add(Event())
    fifo.add(Event())
    fifo.add(Event())
    check(len(fifo.queue) == 3)
    fifo.add(Event())
    check(len(fifo.queue) == 3)

  # TODO test addAndRevise
