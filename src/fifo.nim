## A FIFO-like structure, that only supports put in and overwrites
## the oldest task when full

import options

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

proc addAndRevise*(fifo: var FIFO, event: Event): Option[Event] =
  ## Add an event to the FIFO with potential revision,
  ## return revised element if revision worked, else none
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
      # overlap happened, we can't revise, so just add the event to FIFO
      fifo.add(event)
      return

  let revised = eventRevision(closest, event)
  if revised.truth.confidence < closest.truth.confidence and revised.truth.confidence < event.truth.confidence:
    # Revision into the middle of both occurrence times leaded to truth lower than the premises, don't revise and add event
    fifo.add(event)
    return

  # Else we add the revised one and delete the closest one
  fifo.queue.delete(closest_i) # O(n)
  fifo.add(revised)
  return some(revised)
