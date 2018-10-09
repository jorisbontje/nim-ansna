import event
import implication
import sdr
import stamp
import truth

const REVISION_MAX_OCCURRENCE_DISTANCE = 100

func derivationTimeAndTruth(a: Event, b: Event): (int64, Truth, Truth) =
    let conclusionTime = (a.occurrenceTime + b.occurrenceTime) div 2
    let truthA = projection(a.truth, a.occurrenceTime, conclusionTime)
    let truthB = projection(b.truth, b.occurrenceTime, conclusionTime)
    result = (conclusionTime, truthA, truthB)

# {Event a., Event b.} |- Event (&/,a,b).
proc beliefIntersection*(a: Event, b: Event): Event =
    let (conclusionTime, truthA, truthB) = derivationTimeAndTruth(a, b)

    result = Event(sdr: `tuple`(a.sdr, b.sdr),
                   type: EventType.Belief,
                   truth: intersection(truthA, truthB),
                   stamp: make(a.stamp, b.stamp),
                   occurrenceTime: conclusionTime)

# {Event a., Event b.} |- Implication <a =/> c>.
proc beliefInduction*(a: Event, b: Event): Implication =
    let (conclusionTime, truthA, truthB) = derivationTimeAndTruth(a, b)

    result = Implication(sdr: `tuple`(a.sdr, b.sdr),
                         truth: eternalize(induction(truthA, truthB)),
                         stamp: make(a.stamp, b.stamp),
                         occurrenceTimeOffset: b.occurrenceTime - a.occurrenceTime)

# {Event a., Event a.} |- Event a.
# {Event a!, Event a!} |- Event a!
proc eventRevision*(a: Event, b: Event): Event =
    let (conclusionTime, truthA, truthB) = derivationTimeAndTruth(a, b)

    if abs(a.occurrenceTime - b.occurrenceTime) > REVISION_MAX_OCCURRENCE_DISTANCE:
        return Event() # XXX need other type

    result = Event(sdr: intersection(a.sdr, b.sdr),
                   type: a.type,
                   truth: revision(truthA, truthB),
                   stamp: make(a.stamp, b.stamp),
                   occurrenceTime: conclusionTime)

# {Implication <a =/> b>., <a =/> b>.} |- Implication <a =/> b>.
proc implicationRevision*(a: Implication, b: Implication): Implication =
    result = Implication(sdr: intersection(a.sdr, b.sdr),
                         truth: projection(revision(a.truth, b.truth), a.occurrenceTimeOffset, b.occurrenceTimeOffset),
                         stamp: make(a.stamp, b.stamp),
                         occurrenceTimeOffset: (a.occurrenceTimeOffset + b.occurrenceTimeOffset) div 2)

# {Event a., Implication <a =/> b>.} |- Event b.
proc beliefDeduction*(component: Event, compound: Implication): Event =
    result = Event(sdr: tupleGetSecondElement(compound.sdr, component.sdr),
                   type: EventType.Belief,
                   truth: deduction(compound.truth, component.truth),
                   stamp: make(component.stamp, compound.stamp),
                   occurrenceTime: component.occurrenceTime + compound.occurrenceTimeOffset)

# {Event b!, Implication <a =/> b>.} |- Event a!
proc goalDeduction*(component: Event, compound: Implication): Event =
    result = Event(sdr: tupleGetFirstElement(compound.sdr, component.sdr),
                   type: EventType.Goal,
                   truth: deduction(compound.truth, component.truth),
                   stamp: make(component.stamp, compound.stamp),
                   occurrenceTime: component.occurrenceTime - compound.occurrenceTimeOffset)

# {Event b., Implication <a =/> b>.} |- Event a.
proc beliefAbduction*(component: Event, compound: Implication): Event =
    result = Event(sdr: tupleGetFirstElement(compound.sdr, component.sdr),
                   type: EventType.Belief,
                   truth: abduction(compound.truth, component.truth),
                   stamp: make(component.stamp, compound.stamp),
                   occurrenceTime: component.occurrenceTime - compound.occurrenceTimeOffset)

# {Event a!, Implication <a =/> b>.} |- Event b!
proc goalAbduction*(component: Event, compound: Implication): Event =
    result = Event(sdr: tupleGetSecondElement(compound.sdr, component.sdr),
                   type: EventType.Goal,
                   truth: abduction(compound.truth, component.truth),
                   stamp: make(component.stamp, compound.stamp),
                   occurrenceTime: component.occurrenceTime + compound.occurrenceTimeOffset)