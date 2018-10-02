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
    `type`*: EventType
    truth*: Truth
    stamp*: Stamp
    occurrenceTime*: int64
