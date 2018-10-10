## A truth-expectation-ranked table for Implications, similar as pre- and post-condition table in OpenNARS,
## except that this table supports revision by itself (as in ANSNA implications don't form concepts)

import options

import implication
import inference
import sdr
import stamp
import truth

const TABLE_SIZE = 1000

type
  BeliefTable* = object
    items*: seq[Implication]
    maxSize: int

func initBeliefTable*(maxSize: int = TABLE_SIZE): BeliefTable =
  result.items = newSeq[Implication]()
  result.maxSize = maxSize

proc add*(table: var BeliefTable, imp: Implication): void =
  let impTruthExp = expectation(imp.truth)

  var inserted = false
  for idx, val in table.items.pairs:
    if impTruthExp > expectation(val.truth):
      table.items.insert(imp, idx)
      inserted = true
      break

  if not inserted:
    table.items.add(imp)

  if table.items.len > table.maxSize:
    # evict last item if full
    table.items.del(table.items.high)


func findClosest(table: BeliefTable, imp: Implication): Option[Implication] =
  var bestExpectation = 0.0
  for val in table.items:
    let curExpectation = expectation(similarity(imp.sdr, val.sdr))
    if curExpectation > bestExpectation:
        bestExpectation = curExpectation
        result = some(val)

proc addAndRevise*(table: var BeliefTable, imp: Implication): void =
  # 1. get closest item in the table
  let closest = table.findClosest(imp)

  # 2. if there was one, revise with closest, and add the revised element
  if closest.isSome:
    if not checkOverlap(closest.get.stamp, imp.stamp):
      let revised = implicationRevision(closest.get, imp)
      table.add(revised)

  # 3. add imp too:
  table.add(imp);

func `[]`*(table: BeliefTable, idx: int): Implication =
  table.items[idx]
