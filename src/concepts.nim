import hashes

import attention
import belieftable
import eventfifo
import fifo
import implication
import sdr
import usage

type
  Concept* = object
    attention*: Attention
    usage*: Usage
    sdr*: SDR
    sdrHash*: Hash
    eventBeliefs*: EventFIFO
    eventGoals*: EventFIFO
    preconditionBeliefs*: BeliefTable
    postconditionBeliefs*: BeliefTable

func initConcept*(sdr: SDR, attention=Attention()): Concept =
    result.sdr = sdr
    result.sdrHash = sdr.hash
    result.attention = attention
    result.eventBeliefs = initEventFIFO()
    result.eventGoals = initEventFIFO()
    result.preconditionBeliefs = initBeliefTable()
    result.postconditionBeliefs = initBeliefTable()

func `<`*(a, b: Concept): bool {.inline.} =
  result = a.attention.priority < b.attention.priority

func `==`*(a, b: Concept): bool {.inline.} =
  result = a.sdrHash == b.sdrHash
