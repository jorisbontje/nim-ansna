import math
import random
import tables

import sdr

const SDR_ones = 5

var inputTerms = initTable[int, SDR]()

# https://www.youtube.com/watch?v=V3Yqtpytif0&list=PL3yXMgtrZmDqhsFQzwUC9V8MeeVOQ7eZ9&index=6
proc encodeScalar*(n, w, min, max, value: int): SDR =
    # let n = SDR_size;
    let numberOfBuckets = n - w + 1;
    # determine bucket into which the number falls into
    # see https://arxiv.org/pdf/1602.05925.pdf
    let selectedBucket = int(numberOfBuckets * (value - min) / (max - min))

    # echo "w: ", w, " min: ", min, " max: ", max, " value: ", value
    # echo "n: ", n, " numberOfBuckets: ", numberOfBuckets, " selectedBucket: ", selectedBucket

    result = newSDR()
    # active bits as described in the paper
    for bitIdx in selectedBucket..<selectedBucket + w:
      result.writeBit(bitIdx, true)

proc encodeTerm*(number: int): SDR =
  if inputTerms.hasKey(number):
    return inputTerms[number]

  result = newSDR()
  for i in 0..<SDR_ones:
    let bit = rand(SDR_size - 1)
    result.writeBit(bit, true)

    inputTerms[number] = result
