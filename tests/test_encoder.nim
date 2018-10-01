import sequtils
import unittest

import encoder
import sdr

suite "Encoder":

  # https://arxiv.org/pdf/1602.05925.pdf
  test "encodeScalar examples from paper":
    check(encodeScalar(120, 21, 0, 100, 0).toBits == toSeq(0..20))
    check(encodeScalar(120, 21, 0, 100, 72).toBits == toSeq(72..92))
    check(encodeScalar(120, 21, 0, 100, 100).toBits == toSeq(100..120))

  test "encodeScalar":
    check(encodeScalar(SDR_size, 40, 0, 64, 0).toBits == toSeq(0..39))
    check(encodeScalar(SDR_size, 40, 0, 64, 1).toBits == toSeq(31..70))
    check(encodeScalar(SDR_size, 40, 0, 64, 2).toBits == toSeq(62..101))
    check(encodeScalar(SDR_size, 40, 0, 64, 62).toBits == toSeq(1946..1985))
    check(encodeScalar(SDR_size, 40, 0, 64, 63).toBits == toSeq(1977..2016))
