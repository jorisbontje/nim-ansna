import hashes

import sdr
import stamp
import truth

type
  Implication* = object
    sdr*: SDR
    sdrHash*: Hash
    truth*: Truth
    stamp*: Stamp
    occurrenceTimeOffset*: int64

func initImplication*(sdr: SDR): Implication =
  result.sdr = sdr
  result.sdrHash = sdr.hash
