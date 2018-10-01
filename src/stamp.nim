const STAMP_size = 20
const STAMP_free = -1

# TODO consider using sets or seqs
type
  Stamp* = object
    evidentalBase: array[STAMP_size, int]

proc reset*(stamp: var Stamp): void =
  for i in 0..<STAMP_size:
    stamp.evidentalBase[i] = STAMP_free

proc make*(a: Stamp, b: Stamp): Stamp =
  # TODO implementation
  result = Stamp()

proc checkOverlap*(a: Stamp, b: Stamp): bool =
  # TODO improve by using seq intersection
  for i in 0..<STAMP_size:
    if a.evidentalBase[i] == STAMP_free:
      break

    for j in 0..<STAMP_size:
      if b.evidentalBase[j] == STAMP_free:
        break
      if a.evidentalBase[i] == b.evidentalBase[j]:
        return true
  result = false
