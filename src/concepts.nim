import hashes

import attention
import event
import fifo
import implication
import sdr
import usage

const PRECONDITION_BELIEFS_MAX = 512
const POSTCONDITION_BELIEFS_MAX = 512

type
  Concept* = object
    attention: Attention
    usage: Usage
    sdr*: SDR
    sdrHash*: Hash
    eventBeliefs: FIFO
    eventGoals: FIFO
    preconditionBeliefs: seq[Implication]
    postconditionBeliefs: seq[Implication]

proc initConcept*(sdr: SDR): Concept =
    result.sdr = sdr
    result.sdrHash = sdr.hash
    result.eventBeliefs = initFIFO()
    result.eventGoals = initFIFO()
    result.preconditionBeliefs = newSeq[Implication]()
    result.postconditionBeliefs = newSeq[Implication]()
