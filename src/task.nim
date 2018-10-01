import attention
import sdr
import truth
import stamp

type
  TaskType* {.pure.} = enum
    Goal, Judgement

  Task* = object
    attention*: Attention
    sdr*: SDR
    `type`*: TaskType
    truth*: Truth
    stamp*: Stamp
