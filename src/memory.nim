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
  Memory = object
    concepts: PriQueue[Concept]
    events: PriQueue[Event]
    bitToConcept: Table[int, HashSet[Hash]]

func initMemory*(): Memory =
  result.concepts = initPriQueue[Concept](CONCEPTS_MAX)
  result.events = initPriQueue[Event](EVENTS_MAX)
  result.bitToConcept = initTable[int, HashSet[Hash]]()

proc addConcept*(memory: var Memory, koncept: Concept): void =
  let feedback = memory.concepts.add(koncept)

  # update voting table
  if feedback.added:
    for i in 0..<SDR_size:
      if koncept.sdr.readBit(i):
        if i notin memory.bitToConcept:
          memory.bitToConcept[i] = initSet[Hash]()
        memory.bitToConcept[i].incl(koncept.sdrHash)

  # eviction respondes from voting table
  if feedback.evicted:
    for i in 0..<SDR_size:
      if feedback.evictedElem.sdr.readBit(i):
        if i in memory.bitToConcept:
          memory.bitToConcept[i].excl(koncept.sdrHash)

func findConceptByHash(memory: Memory, sdrHash: Hash): Option[Concept] =
  for koncept in memory.concepts:
      if sdrHash == koncept.sdrHash:
        return some(koncept)

func findClosestConcepByVoting*(memory: Memory, event: Event): Option[Concept] =
  let exactMatch = memory.findConceptByHash(event.sdrHash)
  if exactMatch.isSome:
    return exactMatch

  var voting = newCountTable[Hash]()
  for i in 0..<SDR_size:
    if event.sdr.readBit(i) and i in memory.bitToConcept:
      for conceptSdrHash in memory.bitToConcept[i]:
        voting.inc(conceptSdrHash)

  if voting.len == 0:
    return none(Concept)

  result = memory.findConceptByHash(voting.largest[0])

func findClosestConceptExhaustive*(memory: Memory, event: Event): Option[Concept] =
  var bestValSoFar = -1.0
  for koncept in memory.concepts.items():
      let curVal = expectation(inheritance(event.sdr, koncept.sdr))
      if curVal > bestValSoFar:
          bestValSoFar = curVal
          result = some(koncept)
