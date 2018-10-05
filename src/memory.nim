import hashes
import options
import tables

import concepts
import event
import priorityqueue
import sdr

# TODO update with patham9

# XXX unused
const CONCEPTS_MAX = 10000
const EVENTS_MAX = 64

type
  Memory = PriQueue[Concept]
  AttentionBuffer = PriQueue[Event]

# var memory: Memory
# var buffer: AttentionBuffer

# TODO move into Memory?
var bitToConcept = initTable[int, seq[Hash]]()

proc initMemory*(): Memory =
  result = initPriQueue[Concept]()

proc addConcept*(memory: var Memory, koncept: Concept): void =
  # TODO what is the priority?
  memory.add(koncept, 666)

  # voting table
  for i in 0..<SDR_size:
    if koncept.sdr.readBit(i):
      if i notin bitToConcept:
        bitToConcept[i] = newSeq[Hash]()
      bitToConcept[i].add(koncept.sdrHash)

  # TODO eviction

proc findClosestConceptByNameExhaustive*(memory: Memory, taskSDR: SDR): Option[Concept] =
  var bestValSoFar = -1.0
  for i in 0..<memory.count:
      let curVal = inheritance(taskSDR, memory.buf[i + 1].data.sdr)
      # XXX which part of the Truth to use?
      if curVal.frequency > bestValSoFar:
          bestValSoFar = curVal.frequency
          result = some(memory.buf[i + 1].data)
