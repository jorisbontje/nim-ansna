import options
import unittest

import encoder
import event
import eventfifo
import stamp
import truth

suite "fifo":

  test "addAndRevise patham9":
    const fifoSize = 10
    var fifo = initEventFIFO(maxSize = fifoSize)

    # First, evaluate whether the fifo works, not leading to overflow
    for i in countdown(fifoSize * 2, 1):
      # "rolling over" once by adding a k*FIFO_Size items
      let event1 = Event(sdr: encodeTerm("test"),
                         type: EventType.Belief,
                         truth: Truth(frequency: 1.0, confidence: 0.9),
                         stamp: Stamp(evidentalBase: [i].toEvidentalBase),
                         occurrenceTime: i*10)
      fifo.add(event1)

    for i in 0 ..< fifoSize:
      check fifo[i].stamp.evidentalBase[0] == fifoSize - i

    # now see whether a new item is revised with the correct one:
    let i = 10 # revise with item 10, which has occurrence time 10
    let newbase = fifoSize * 2 + 1
    let event2 = Event(sdr: encodeTerm("test"),
                       type:  EventType.Belief,
                       truth: Truth(frequency: 1.0, confidence: 0.9),
                       stamp: Stamp(evidentalBase: [newBase].toEvidentalBase),
                       occurrenceTime: i * 10 + 3)

    let ret = fifo.addAndRevise(event2).get

    check ret.occurrenceTime > i * 10 and ret.occurrenceTime < i * 10 + 3
    check ret.stamp.evidentalBase[0] == i and ret.stamp.evidentalBase[1] == newbase
    check fifo[fifoSize - i].stamp.evidentalBase[0] != fifoSize - i # as it was replaced

    let addedRet = fifo[fifo.high]
    check addedRet.stamp.evidentalBase[0] == i and addedRet.stamp.evidentalBase[1] == newbase #it is at the first position of the FIFO now
    echo ret.truth.frequency, " ", ret.truth.confidence
    check ret.truth.confidence > 0.9
