import sdr
import stamp
import task
import truth

# {Event task a., Event belief b.} |- Derived event task (&/,a,b).
proc beliefEventIntersection*(a: Task, b: Task): Task =
    let conclusionTruth = intersection(a.truth, b.truth)
    let sdr = `tuple`(a.sdr, b.sdr)
    let stamp = make(a.stamp, b.stamp)
    result = Task(sdr: sdr, type: TaskType.Judgement, truth: conclusionTruth, stamp: stamp)

# {Event task a., Event belief b.} |- Precondition and Postcondition belief <a =/> c>.
proc beliefInduction*(subject: Task, predicate: Task): Task =
    let conclusionTruth = induction(subject.truth, predicate.truth)
    let sdr = `tuple`(subject.sdr, predicate.sdr)
    let stamp = make(subject.stamp, predicate.stamp)
    result = Task(sdr: sdr, type: TaskType.Judgement, truth: conclusionTruth, stamp: stamp)

# {Precondition or Postcondition belief a., Precondition or Postcondition belief a.} |-
#  Precondition or Postcondition belief a.
proc beliefRevision*(a: Task, b: Task): Task =
    let conclusionTruth = revision(a.truth, b.truth);
    let sdr = a.sdr;
    let stamp = make(a.stamp, b.stamp);
    result = Task(sdr: sdr, type: TaskType.Judgement, truth: conclusionTruth, stamp: stamp)

# {Event task a., Postcondition belief <a =/> b>.} |- Derived event task b.
proc beliefEventDeduction*(component: Task, compound: Task): Task =
    let conclusionTruth = deduction(compound.truth, component.truth)
    let sdr = tupleGetSecondElement(compound.sdr, component.sdr)
    let stamp = make(component.stamp, compound.stamp)
    result = Task(sdr: sdr, type: TaskType.Judgement, truth: conclusionTruth, stamp: stamp)

# {Event task b!, Postcondition belief <a =/> b>.} |- Derived event task a!
proc goalEventDeduction*(component: Task, compound: Task): Task =
    let conclusionTruth = deduction(compound.truth, component.truth)
    let sdr = tupleGetFirstElement(compound.sdr, component.sdr)
    let stamp = make(component.stamp, compound.stamp)
    # XXX TaskType should be GOAL
    # https://github.com/patham9/ANSNA/issues/18
    result = Task(sdr: sdr, type: TaskType.Goal, truth: conclusionTruth, stamp: stamp)

# {Event task b., Postcondition belief <a =/> b>.} |- Derived event task a.
proc beliefEventAbduction*(component: Task, compound: Task): Task =
    let conclusionTruth = abduction(compound.truth, component.truth)
    let sdr = tupleGetFirstElement(compound.sdr, component.sdr)
    let stamp = make(component.stamp, compound.stamp)
    result = Task(sdr: sdr, type: TaskType.Judgement, truth: conclusionTruth, stamp: stamp)

# {Event task a!, Precondition belief <a =/> b>.} |- Derived event task b!
proc goalEventAbduction*(component: Task, compound: Task): Task =
    let conclusionTruth = abduction(compound.truth, component.truth)
    let sdr = tupleGetSecondElement(compound.sdr, component.sdr)
    let stamp = make(component.stamp, compound.stamp)
    result = Task(sdr: sdr, type: TaskType.Goal, truth: conclusionTruth, stamp: stamp)
