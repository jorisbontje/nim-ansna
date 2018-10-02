const STAMP_size* = 20
const STAMP_free* = -1

# TODO consider using sets or seqs
type
  Stamp* = object
    evidentalBase*: array[STAMP_size, int]

proc initStamp*(): Stamp =
  for i in 0..<STAMP_size:
    result.evidentalBase[i] = STAMP_free

proc make*(a: Stamp, b: Stamp): Stamp =
  # TODO implementation
  result = initStamp()

  var processStamp1 = true
  var processStamp2 = true
  var j = 0
  for i in 0..<STAMP_size:
    if processStamp1:
      if a.evidentalBase[j] != STAMP_free:
        result.evidentalBase[j] = a.evidentalBase[i]
        j += 1
        if j >= STAMP_size:
          break
      else:
        processStamp1 = false;

    if processStamp2:
      if b.evidentalBase[j] != STAMP_free:
        result.evidentalBase[j] = b.evidentalBase[i];
        j += 1
        if j >= STAMP_size:
            break
      else:
        processStamp2 = false;

    if not processStamp1 and not processStamp2:
      break

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
