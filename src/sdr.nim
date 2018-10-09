import bitarray
import bitops
import hashes
import random
import strutils

import permutation
import truth

type
  SDR* = distinct BitArray

const SDR_size* = 2048
const SDR_blocks = int(SDR_size / (sizeof(BitArrayScalar) * 8))
const BitArray_header_size = 1

proc newSDR*(): SDR =
  result = SDR(create_bitarray(SDR_size))

func readBit*(sdr: SDR, pos: int): bool {.inline.} =
  var sdr = sdr # XXX workaround for mutable ref
  result = BitArray(sdr)[pos]

proc writeBit*(sdr: var SDR, pos: int, value: bool): void {.inline.} =
  BitArray(sdr)[pos] = value

func toBits*(sdr: SDR): seq[int] =
  for i in 0..<SDR_size:
    if sdr.readBit(i):
      result.add(i)

proc toSDR*(bits: openarray[int]): SDR =
  result = newSDR()
  for i in bits:
    result.writeBit(i, true)

func `$`*(sdr: SDR): string =
  result.add("[")
  result.add(sdr.toBits.join(","))
  result.add("]")

proc minus*(a, b: SDR): SDR =
  result = newSDR()
  for i in 1..SDR_blocks:
    BitArray(result).bitarray[i] = BitArray(a).bitarray[i] and not BitArray(b).bitarray[i]

proc union*(a, b: SDR): SDR =
  result = newSDR()
  for i in 1..SDR_blocks:
    BitArray(result).bitarray[i] = BitArray(a).bitarray[i] or BitArray(b).bitarray[i]

proc intersection*(a, b: SDR): SDR =
  result = newSDR()
  for i in 1..SDR_blocks:
    BitArray(result).bitarray[i] = BitArray(a).bitarray[i] and BitArray(b).bitarray[i]

proc `xor`*(a, b: SDR): SDR =
  result = newSDR()
  for i in 1..SDR_blocks:
    BitArray(result).bitarray[i] = BitArray(a).bitarray[i] xor BitArray(b).bitarray[i]

# proc swap*(sdr: var SDR, bit_i: int, bit_j: int): void =
#   let temp = readBit(sdr, bit_i)
#   sdr.writeBit(bit_i, sdr.readBit(bit_j))
#   sdr.writeBit(bit_j, temp)

proc copy*(sdr: SDR): SDR =
  result = newSDR()
  for i in 1..SDR_blocks:
    BitArray(result).bitarray[i] = BitArray(sdr).bitarray[i]

proc permuteByRotation*(sdr: SDR, forward: bool): SDR =
  # XXX unoptimized
  result = newSDR()
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

proc set*(a, b: SDR): SDR =
  result = union(a, b)

proc permute*(a: SDR, perm: Permutation): SDR =
  result = newSDR()
  for i in 0..<SDR_size:
    result.writeBit(i, a.readBit(perm[i]))

proc `tuple`*(a, b: SDR): SDR =
  var aPerm = permute(a, permS)
  var bPerm = permute(b, permP)
  result = `xor`(aPerm, bPerm)

proc tupleGetFirstElement*(compound, secondElement: SDR): SDR =
  var bPerm = permute(secondElement, permP)
  var sdrxor = `xor`(bperm, compound)
  result = permute(sdrxor, permS_inv)

proc tupleGetSecondElement*(compound, firstElement: SDR): SDR =
  var aPerm = permute(firstElement, permS)
  var sdrxor = `xor`(aPerm, compound)
  result = permute(sdrxor, permP_inv)

func match*(part, full: SDR): Truth =
  var countOneInBoth = 0
  var generalCaseMisses1Bit = 0

  for i in 0..<SDR_size:
    countOneInBoth += int(part.readBit(i) and full.readBit(i))
    generalCaseMisses1Bit += int(not part.readBit(i) and full.readBit(i))

  let e_total = float(countOneInBoth + generalCaseMisses1Bit)
  let f_total = float(countOneInBoth) / e_total
  result = Truth(frequency: f_total, confidence: w2c(e_total))

func inheritance*(full, part: SDR): Truth =
  result = match(part, full)

func similarity*(a, b: SDR): Truth =
  result = intersection(match(a, b), match(b, a))

func hash*(sdr: SDR): Hash =
  var h: Hash = 0
  for i in 0 ..< SDR_blocks:
    h = h !& hash(BitArray(sdr).bitarray[i + BitArray_header_size])
  result = !$h

func countTrue*(sdr: SDR): int =
  for i in 0 ..< SDR_blocks:
    result += countSetBits(BitArray(sdr).bitarray[i + BitArray_header_size])
