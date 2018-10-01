import unittest

import truth

suite "truth":

  test "expectation":
    check expectation(Truth(frequency: 1.4, confidence: 2.5)) == 2.75
    check expectation(Truth(frequency: 2, confidence: 6)) == 9.5

  test "revision":
    check(revision(Truth(frequency: 1, confidence: 0.5),
                   Truth(frequency: 2, confidence: 0.3)) ==
                   Truth(frequency: 1.3, confidence: 0.588235294117647))
    check(revision(Truth(frequency: 4, confidence: 0.1),
                   Truth(frequency: 1, confidence: 0.96)) ==
                   Truth(frequency: 1.0138248847926268, confidence: 0.9601769911504424))

  test "deduction":
    check(deduction(Truth(frequency: 1, confidence: 2),
                    Truth(frequency: 3, confidence: 4)) ==
                    Truth(frequency: 3, confidence: 24))

  test "abduction":
    check(abduction(Truth(frequency: 1, confidence: 2),
                    Truth(frequency: 3, confidence: 4)) ==
                    Truth(frequency: 1, confidence: 0.96))

  test "induction":
    check(induction(Truth(frequency: 3, confidence: 6),
                    Truth(frequency: 1, confidence: 7)) ==
                    Truth(frequency: 1, confidence: 0.9921259842519685))

  test "intersection":
    check(intersection(Truth(frequency: 1, confidence: 2),
                       Truth(frequency: 5, confidence: 4)) ==
                       Truth(frequency: 5, confidence: 8))
