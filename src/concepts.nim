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
    name*: SDR ## name of the concept like in OpenNARS
    nameHash*: Hash
    eventBeliefs: FIFO
    eventGoals: FIFO
    preconditionBeliefs: seq[Implication]
    postconditionBeliefs: seq[Implication]

proc initConcept*(name: SDR): Concept =
    result.name = name
    result.eventBeliefs = initFIFO()
    result.eventGoals = initFIFO()
    result.preconditionBeliefs = newSeq[Implication]()
    result.postconditionBeliefs = newSeq[Implication]()
    # Generate CRC checksum too:
    result.nameHash = name.hash
