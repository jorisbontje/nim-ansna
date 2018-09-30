import truth
import usage

type
  Attention* = object
    priority: float
    durability: float

proc forgetTask*(taskAttention: Attention): Attention =
  result = Attention(priority: taskAttention.priority * taskAttention.durability,
                     durability: taskAttention.durability)

const USEFULNESS_MAX_PRIORITY_BARRIER = 0.1

proc forgetConcept*(conceptAttention: Attention, conceptUsage: Usage, currentTime: int64): Attention =
  let usefulness = usefulness(conceptUsage, currentTime)
  let lowerPriorityBarrier = usefulness * USEFULNESS_MAX_PRIORITY_BARRIER
  result = Attention(priority: max(lowerPriorityBarrier, conceptAttention.priority * conceptAttention.durability),
                     durability: conceptAttention.durability)

proc `or`(a: float, b: float): float =
  result = if a != 0: a else: b

proc activateConcept*(conceptAttention: Attention, taskAttention: Attention): Attention =
  result = Attention(priority: conceptAttention.priority or taskAttention.priority,
                     durability: conceptAttention.durability)

proc deriveTask*(conceptAttention: Attention, beliefTruth: Truth): Attention =
  result = Attention(priority: conceptAttention.priority * expectation(beliefTruth),
                     durability: conceptAttention.durability)
