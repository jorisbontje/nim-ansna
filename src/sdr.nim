import bitarray
import hashes
import random
import strutils

import permutation
import truth

type
  SDR* = ref object
    bitarray: BitArray

const SDR_size = 2048
const SDR_blocks = int(SDR_size / (sizeof(BitArrayScalar) * 8))
const BitArray_header_size = 1

proc new_SDR*(): SDR =
  result = new SDR
  result.bitarray = create_bitarray(SDR_size)

proc readBit*(sdr: SDR, pos: int): bool =
  result = sdr.bitarray[pos]

proc writeBit*(sdr: SDR, pos: int, value: bool): void =
  sdr.bitarray[pos] = value

proc toBits*(sdr: SDR): seq[int] =
  for i in 0..<SDR_size:
    if sdr.readBit(i):
      result.add(i)

proc toSDR*(bits: openarray[int]): SDR =
  result = new_SDR()
  for i in bits:
    result.writeBit(i, true)

proc `$`*(sdr: SDR): string =
  result.add("[")
  result.add(sdr.toBits.join(","))
  result.add("]")

proc minus*(a: SDR, b: SDR): SDR =
  result = new_SDR()
  for i in 0..<SDR_size:
    result.writeBit(i, a.readBit(i) and not b.readBit(i))

proc union*(a: SDR, b: SDR): SDR =
  result = new_SDR()
  for i in 0..<SDR_size:
    result.writeBit(i, a.readBit(i) or b.readBit(i))

proc intersection*(a: SDR, b: SDR): SDR =
  result = new_SDR()
  for i in 0..<SDR_size:
    result.writeBit(i, a.readBit(i) and b.readBit(i))

proc `xor`*(a: SDR, b: SDR): SDR =
  result = new_SDR()
  for i in 0..<SDR_size:
    writeBit(result, i, a.readBit(i) xor b.readBit(i))

proc swap*(sdr: SDR, bit_i: int, bit_j: int): void =
  let temp = readBit(sdr, bit_i)
  sdr.writeBit(bit_i, sdr.readBit(bit_j))
  sdr.writeBit(bit_j, temp)

proc copy*(sdr: SDR): SDR =
  result = new_SDR()
  for i in 0..<SDR_size:
    writeBit(result, i, sdr.readBit(i))

proc permuteByRotation*(sdr: SDR, forward: bool): SDR =
  result = new_SDR()
  if forward:
    for i in 0..<SDR_size - 1:
      writeBit(result, i + 1, sdr.readBit(i))
  else:
    for i in 1..<SDR_size:
      writeBit(result, i - 1, sdr.readBit(i))

var rnd = initRand(42)
let permS* = randomPermutation(rnd, SDR_size)
let permS_inv* = inversePermutation(permS)
let permP* = randomPermutation(rnd, SDR_size)
let permP_inv* = inversePermutation(permP)

proc set*(a: SDR, b: SDR): SDR =
  result = union(a, b)

proc permute*(a: SDR, perm: Permutation): SDR =
  result = new_SDR()
  for i in 0..<SDR_size:
    result.writeBit(i, a.readBit(perm[i]))

proc `tuple`*(a: SDR, b: SDR): SDR =
  result = `xor`(permute(a, permS), permute(b, permP))

proc tupleGetFirstElement*(compound: SDR, secondElement: SDR): SDR =
  let bPerm = permute(secondElement, permP)
  let sdrxor = `xor`(bperm, compound)
  result = permute(sdrxor, permS_inv)

proc tupleGetSecondElement*(compound: SDR, firstElement: SDR): SDR =
  let aPerm = permute(firstElement, permS)
  let sdrxor = `xor`(aPerm, compound)
  result = permute(sdrxor, permP_inv)

proc match*(part: SDR, full: SDR): Truth =
  var countOneInBoth = 0
  var generalCaseMisses1Bit = 0

  for i in 0..<SDR_size:
    countOneInBoth += int(part.readBit(i) and full.readBit(i))
    generalCaseMisses1Bit += int(not part.readBit(i) and full.readBit(i))

  let e_total = float(countOneInBoth + generalCaseMisses1Bit)
  let f_total = float(countOneInBoth) / float(e_total)
  result = Truth(frequency: f_total, confidence: w2c(e_total))

proc inheritance*(full: SDR, part: SDR): Truth =
  result = match(part, full)

proc similarity*(a: SDR, b: SDR): Truth =
  result = intersection(match(a, b), match(b, a))

proc hash*(sdr: SDR): Hash =
  ### original hashing algorithm:
  # for i in 0 ..< SDR_blocks:
  #   for j in 0 ..< SDR_hash_pieces:
  #     let shift_right = j * 8 * sizeof(SDR_hash)
  #     result = result or (sdr.bitarray.bitarray[i + BitArray_header_size] shr shift_right)
  var h: Hash = 0
  for i in 0 ..< SDR_blocks:
    h = h !& hash(sdr.bitarray.bitarray[i + BitArray_header_size])
  result = !$h
