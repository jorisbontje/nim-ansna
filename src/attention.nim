import truth
import usage

type
  Attention* = object
    priority*: float
    durability*: float

func forgetEvent*(taskAttention: Attention): Attention =
  ## Relative forget a task after it goes through attention buffer
  result = Attention(priority: taskAttention.priority * taskAttention.durability,
                     durability: taskAttention.durability)

const USEFULNESS_MAX_PRIORITY_BARRIER = 0.1

func forgetConcept*(conceptAttention: Attention, conceptUsage: Usage, currentTime: int64): Attention =
  ## Relatively forget a concept after it received a task
  let usefulness = usefulness(conceptUsage, currentTime)
  let lowerPriorityBarrier = usefulness * USEFULNESS_MAX_PRIORITY_BARRIER
  result = Attention(priority: max(lowerPriorityBarrier, conceptAttention.priority * conceptAttention.durability),
                     durability: conceptAttention.durability)

func `or`(a: float, b: float): float {.inline.}  =
  result = if a != 0: a else: b

func activateConcept*(conceptAttention: Attention, taskAttention: Attention): Attention =
  ## Activate a concept with an event
  result = Attention(priority: conceptAttention.priority or taskAttention.priority,
                     durability: conceptAttention.durability)

func deriveEvent*(conceptAttention: Attention, beliefTruth: Truth): Attention =
  ## Derive an event
  result = Attention(priority: conceptAttention.priority * expectation(beliefTruth),
                     durability: conceptAttention.durability)
