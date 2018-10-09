import hashes

import attention
import eventfifo
import fifo
import implication
import sdr
import usage

const PRECONDITION_BELIEFS_MAX = 512
const POSTCONDITION_BELIEFS_MAX = 512

type
  Concept* = object
    attention*: Attention
    usage*: Usage
    sdr*: SDR
    sdrHash*: Hash
    eventBeliefs*: EventFIFO
    eventGoals*: EventFIFO
    preconditionBeliefs*: seq[Implication]
    postconditionBeliefs*: seq[Implication]

func initConcept*(sdr: SDR): Concept =
    result.sdr = sdr
    result.sdrHash = sdr.hash
    result.eventBeliefs = initEventFIFO()
    result.eventGoals = initEventFIFO()
    result.preconditionBeliefs = newSeq[Implication]()
    result.postconditionBeliefs = newSeq[Implication]()

func `<`*(a, b: Concept): bool {.inline.} =
  result = a.attention.priority < b.attention.priority
func `==`*(a, b: Concept): bool {.inline.} =
  result = a.sdrHash == b.sdrHash
