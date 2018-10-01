import hashes

import attention
import sdr
import task
import usage

const PRECONDITION_BELIEFS_MAX = 512
const POSTCONDITION_BELIEFS_MAX = 512
const EVENT_BELIEFS_MAX = 512

type
  Concept* = object
    attention: Attention
    usage: Usage
    # name of the concept like in OpenNARS
    name*: SDR
    nameHash*: Hash
    eventBeliefs: seq[Task]
    preconditionBeliefs: seq[Task]
    postconditionBeliefs: seq[Task]

proc initConcept*(name: SDR): Concept =
    result.name = name
    result.eventBeliefs = newSeq[Task]()
    result.preconditionBeliefs = newSeq[Task]()
    result.postconditionBeliefs = newSeq[Task]()
    # Generate CRC checksum too:
    result.nameHash = name.hash
