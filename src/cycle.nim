## ALANN Control Cycle

import options

import attention
import belieftable
import concepts
import event
import eventfifo
import inference
import implication
import memory
import priorityqueue
import stamp

const EVENT_SELECTIONS = 10

# for temporal induction
const CONCEPT_SELECTIONS = 10

var currentTime = 0

proc composition(B, A: var Concept, b: Event): void =
  # temporal induction and intersection
  if A.eventBeliefs.len > 0:
    let a = A.eventBeliefs.head  # most recent, highest revised
    # XXX dont need to test for: a.type != EventType.Deleted
    if not checkOverlap(a.stamp, b.stamp):
      let result = beliefInduction(a, b)
      B.preconditionBeliefs.addAndRevise(result)
      A.postconditionBeliefs.addAndRevise(result)

proc decomposition(mem: var Memory, c: var Concept, e: Event): void =
  # detachment
  if e.type == EventType.Belief:
    if c.postconditionBeliefs.len > 0:
      let postcon = c.postconditionBeliefs[0]
      if not checkOverlap(e.stamp, postcon.stamp):
        var res = beliefDeduction(e, postcon)
        res.attention = deriveEvent(c.attention, postcon.truth)
        c.postconditionBeliefs[0] = assumptionOfFailure(postcon) # TODO do better
        discard mem.events.add(res)

    if c.preconditionBeliefs.len > 0:
      let precon = c.preconditionBeliefs[0]
      if not checkOverlap(e.stamp, precon.stamp):
        var res = beliefAbduction(e, precon)
        res.attention = deriveEvent(c.attention, precon.truth)
        discard mem.events.add(res)

    elif e.type == EventType.Goal:
      if c.postconditionBeliefs.len > 0:
        let postcon = c.postconditionBeliefs[0]
        if not checkOverlap(e.stamp, postcon.stamp):
          var res = goalAbduction(e, postcon)
          res.attention = deriveEvent(c.attention, postcon.truth)
          discard mem.events.add(res)

      if c.precondition_beliefs.len > 0:
        let precon = c.precondition_beliefs[0]
        if not checkOverlap(e.stamp, precon.stamp):
          var res = goalDeduction(e, precon)
          res.attention = deriveEvent(c.attention, precon.truth)
          discard mem.events.add(res)

proc cycle*(mem: var Memory): void =
  ## Apply one inference cyle

  for i in 0 ..< EVENT_SELECTIONS:
    # 1. get an event from the event queue
    var e = mem.events.pop
    # determine the concept it is related to
    let closest_concept = mem.findClosestConcepByVoting(e)
    if closest_concept.isNone:
      continue

    var c = closest_concept.get
    # apply decomposition-based inference: prediction/explanation
    decomposition(mem, c, e)
    # add event to the FIFO of the concept
    var fifo = if e.type == EventType.Belief: c.event_beliefs else: c.event_goals
    let revised = fifo.addAndRevise(e)
    if revised.isSome:
        discard mem.events.add(revised.get)

    # relatively forget the event, as it was used, and add back to events
    e.attention = forgetEvent(e.attention)
    discard mem.events.add(e)

    # trigger composition-based inference hypothesis formation
    for j in 0 ..< CONCEPT_SELECTIONS:
        var d = mem.concepts.pop
        composition(c, d, e)  # deriving a =/> b

    # activate concepts attention with the event's attention
    c.attention = activateConcept(c.attention, e.attention)
    # TODO PriorityQueue_bubbleUp(&concepts, closest_concept_i); # priority was increased
    # XXX mem.concepts.bubbleUp(closest_concept_i)  # priority was increased

    # add a new concept for e too at the end, just before it needs to be identified with something existing
    # TODO review
    var koncept = initConcept(e.sdr)
    koncept.attention = activateConcept(c.attention, e.attention)
    mem.addConcept(koncept)

  # relative forget concepts:
  for koncept in mem.concepts.mitems:
    # as all concepts are forgotten the order won't change
    # making this operation very cheap, not demanding any heap operation
    koncept.attention = forgetConcept(koncept.attention, koncept.usage, currentTime)

  currentTime += 1

