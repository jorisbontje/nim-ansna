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
import sdr
import stamp
import truth

const EVENT_SELECTIONS = 10

# for temporal induction
const CONCEPT_SELECTIONS = 10

var currentTime* = 0

proc composition(mem: var Memory, B, A: var Concept, b: Event): void =
  # temporal induction and intersection
  if b.type == EventType.Belief and A.eventBeliefs.len > 0:
    let a = A.eventBeliefs.head  # most recent, highest revised
    # XXX dont need to test for: a.type != EventType.Deleted
    # https://github.com/patham9/ANSNA/issues/29
    if not checkOverlap(a.stamp, b.stamp):
      let implication = beliefInduction(a, b)
      B.preconditionBeliefs.addAndRevise(implication)
      A.postconditionBeliefs.addAndRevise(implication)
      let sequence = if b.occurrenceTime > a.occurrenceTime:
                       beliefIntersection(a, b)
                     else:
                       beliefIntersection(b, a)
      discard mem.events.add(sequence)

proc decomposition(mem: var Memory, c: var Concept, e: Event): void =
  # detachment
  if c.postconditionBeliefs.len > 0:
    let postcon = c.postconditionBeliefs[0]
    if not checkOverlap(e.stamp, postcon.stamp):
      var res = if e.type == EventType.Belief:
          beliefDeduction(e, postcon)
        else:
          goalAbduction(e, postcon)
      res.attention = deriveEvent(c.attention, postcon.truth)
      discard mem.events.add(res)

      # add negative evidence to the used predictive hypothesis (assumption of failure, for extinction)
      discard c.postconditionBeliefs.popHighestTruthExpectationElement()
      let updated = assumptionOfFailure(postcon)
      c.postconditionBeliefs.add(updated)

  if c.preconditionBeliefs.len > 0:
    let precon = c.preconditionBeliefs[0]
    if not checkOverlap(e.stamp, precon.stamp):
      var res = if e.type == EventType.Belief:
          beliefAbduction(e, precon)
        else:
          goalDeduction(e, precon)
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

    var (c_idx, c) = closest_concept.get

    let matchTruth = inheritance(e.sdr, c.sdr)
    var eMatch = e
    eMatch.truth = revision(e.truth, matchTruth)
    # apply decomposition-based inference: prediction/explanation
    decomposition(mem, c, eMatch)
    # add event to the FIFO of the concept
    var fifo = if e.type == EventType.Belief: c.event_beliefs else: c.event_goals
    let revised = fifo.addAndRevise(eMatch)
    if revised.isSome:
        discard mem.events.add(revised.get)

    # relatively forget the event, as it was used, and add back to events
    e.attention = forgetEvent(e.attention)
    discard mem.events.add(e)

    # trigger composition-based inference hypothesis formation
    for j in 0 ..< CONCEPT_SELECTIONS:
        var d = mem.concepts.pop
        composition(mem, c, d, eMatch)  # deriving a =/> b

    # activate concepts attention with the event's attention
    c.attention = activateConcept(c.attention, e.attention)
    mem.concepts.replace(c_idx, c)  # priority was increased

    # add a new concept for e too at the end, just before it needs to be identified with something existing
    let koncept = initConcept(e.sdr, attention=activateConcept(c.attention, e.attention))
    mem.addConcept(koncept)

  # relative forget concepts:
  for koncept in mem.concepts.mitems:
    # as all concepts are forgotten the order won't change
    # making this operation very cheap, not demanding any heap operation
    koncept.attention = forgetConcept(koncept.attention, koncept.usage, currentTime)

  currentTime += 1
