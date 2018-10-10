import unittest

import belieftable
import encoder
import implication
import truth
import stamp

suite "belieftable":

  test "add, addAndRevise patham9":
    const tableSize = 10
    var table = initBeliefTable(maxSize = tableSize)

    for i in countdown(tableSize * 2, 1):
      let imp = Implication(sdr: encodeTerm("test"),
                            truth: Truth(frequency: 1.0, confidence: 1.0 / float(i + 1)),
                            stamp: Stamp(evidentalBase: [i].toEvidentalBase),
                            occurrenceTimeOffset: 10)
      table.add(imp)

    for i in 0 ..< tableSize:
      # Item at table position has to be right
      check table[i].stamp.evidentalBase[0] == i + 1

    # Implication imp = (Implication) { .sdr = Encode_Term("test"),
    #                                   .truth = (Truth) { .frequency = 1.0, .confidence = 0.9},
    #                                   .stamp = (Stamp) { .evidentalBase = {TABLE_SIZE*2+1} },
    #                                   .occurrenceTimeOffset = 10 };

    let imp = Implication(sdr: encodeTerm("test"),
                          truth: Truth(frequency: 1.0, confidence: 0.9),
                          stamp: Stamp(evidentalBase: [tableSize * 2 + 1].toEvidentalBase),
                          occurrenceTimeOffset: 10)

    # The highest confidence one should be the first.
    check table[0].truth.confidence == 0.5

    table.addAndRevise(imp)
    # The revision result should be more confident than the premises.
    check table[0].truth.confidence > 0.9
