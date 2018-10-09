import hashes

import attention
import sdr
import truth
import stamp

type
  EventType* {.pure.} = enum
    Goal, Belief

  Event* = object
    attention*: Attention
    sdr*: SDR
    sdrHash*: Hash
    `type`*: EventType
    truth*: Truth
    stamp*: Stamp
    occurrenceTime*: int64

func initEvent*(sdr: SDR): Event =
  result.sdr = sdr
  result.sdrHash = sdr.hash
