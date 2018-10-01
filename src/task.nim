import attention
import sdr
import truth
import stamp

type
  TaskType = enum
    tGoal, tJudgement

  Task = object
    attention: Attention
    sdr: SDR
    `type`: TaskType
    truth: Truth
    stamp: Stamp
