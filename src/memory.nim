import hashes
import options
import sets
import tables

import concepts
import event
import priorityqueue
import sdr
import truth

# TODO update with patham9

const CONCEPTS_MAX = 10000
const EVENTS_MAX = 64

type
  Memory = PriQueue[Concept]
  AttentionBuffer = PriQueue[Event]

# TODO move into Memory?
var bitToConcept = initTable[int, HashSet[Hash]]()

proc initMemory*(): Memory =
  result = initPriQueue[Concept](CONCEPTS_MAX)

proc addConcept*(memory: var Memory, koncept: Concept): void =
  let feedback = memory.add(koncept)

  # voting table
  if feedback.added:
    for i in 0..<SDR_size:
      if koncept.sdr.readBit(i):
        if i notin bitToConcept:
          bitToConcept[i] = initSet[Hash]()
        bitToConcept[i].incl(koncept.sdrHash)

  # eviction
  if feedback.evicted:
    for i in 0..<SDR_size:
      if feedback.evictedElem.sdr.readBit(i):
        if i in bitToConcept:
          bitToConcept[i].excl(koncept.sdrHash)

# TODO
# proc findClosestConceptByVoting

proc findClosestConceptByNameExhaustive*(memory: Memory, taskSDR: SDR): Option[Concept] =
  var bestValSoFar = -1.0
  for koncept in memory.items():
      let curVal = expectation(inheritance(taskSDR, koncept.sdr))
      if curVal > bestValSoFar:
          bestValSoFar = curVal
          result = some(koncept)
