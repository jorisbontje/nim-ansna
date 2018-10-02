import sdr
import stamp
import truth

type
  Implication* = object
    sdr*: SDR
    truth*: Truth
    stamp*: Stamp
    occurrenceTimeOffset*: int64
