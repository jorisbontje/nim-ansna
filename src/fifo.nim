## A FIFO-like structure, that only supports put in and overwrites
## the oldest task when full

import event
import inference
import stamp
import truth

const FIFO_MAX_SIZE = 1000

type
  FIFO* = object
    queue*: seq[Event]
    maxSize: int

proc initFIFO*(maxSize: int = FIFO_MAX_SIZE): FIFO =
  result.queue = newSeq[Event]()
  result.maxSize = maxSize

proc add*(fifo: var FIFO, event: Event): void =
  # TODO optimize using deques?
  fifo.queue.add(event)
  if fifo.queue.len > fifo.maxSize:
    fifo.queue.delete(0) # O(n)

proc addAndRevise*(fifo: var FIFO, event: Event): Event =
  ## Add an event to the FIFO with potential revision,
  ## return revised element if revision worked, else event
  ## also see https://github.com/patham9/ANSNA/wiki/Event-Revisio

  var closest: Event
  var closest_i = -1

  for i, item in fifo.queue.pairs():
    if closest_i < 0:
      closest = item
      closest.truth = projection(closest.truth, closest.occurrenceTime, event.occurrenceTime)
      closest_i = i
    else:
      var potentialClosest = item
      potentialClosest.truth = projection(potentialClosest.truth, potentialClosest.occurrenceTime, event.occurrenceTime)
      if potentialClosest.truth.confidence > closest.truth.confidence:
        closest = potentialClosest
        closest_i = i

  if checkOverlap(event.stamp, closest.stamp):
    fifo.add(event)
    return event

  let revised = eventRevision(closest, event)
  fifo.queue.delete(closest_i) # O(n)
  fifo.add(revised)
  return revised
