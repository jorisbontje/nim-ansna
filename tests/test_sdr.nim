import sequtils
import unittest

import sdr

suite "SDR":

  test "$":
    var sdr = newSDR()
    check($sdr == "[]")
    sdr.writeBit(0, true)
    check($sdr == "[0]")
    sdr.writeBit(1, true)
    check($sdr == "[0,1]")

  test "set get":
    var sdr = newSDR()
    sdr.writeBit(1, true)
    check(sdr.readBit(1))
    sdr.writeBit(1, false)
    check(not sdr.readBit(1))

  test "toSDR toBits":
    let sdr = [1,3,5,2047].toSDR
    check(sdr.toBits == [1,3,5,2047])

  test "minus":
    let sdr1 = [1,2,2047].toSDR
    let sdr2 = [2].toSDR
    let sdr3 = minus(sdr1, sdr2)
    check(sdr3.toBits == [1,2047])

  test "union":
    let sdr1 = [1,2047].toSDR
    let sdr2 = [2].toSDR
    var sdr3 = union(sdr1, sdr2)
    check(sdr3.toBits == [1,2,2047])

  test "intersection":
    let sdr1 = [1,2].toSDR
    let sdr2 = [2,2047].toSDR
    var sdr3 = intersection(sdr1, sdr2)
    check(sdr3.toBits == [2])

  test "xor":
    let sdr1 = [1,2,2047].toSDR
    let sdr2 = [2,3].toSDR
    var sdr3 = `xor`(sdr1, sdr2)
    check(sdr3.toBits == [1,3,2047])

  test "swap":
    let sdr1 = [1,3].toSDR
    sdr1.swap(1, 2)
    check(sdr1.toBits == [2,3])

  test "copy":
    let sdr1 = [1,2047].toSDR
    var sdr2 = sdr1.copy()
    check(sdr2.toBits == [1,2047])

  test "permuteByRotation":
    let sdr = [1].toSDR
    var sdrForward = sdr.permuteByRotation(true)
    check(sdrForward.toBits == [2])
    var sdrBackward = sdr.permuteByRotation(false)
    check(sdrBackward.toBits == [0])

  test "tuple":
    let sdr1 = [1,3,5].toSDR
    let sdr2 = [2,4,6].toSDR
    var sdrCombined = `tuple`(sdr1, sdr2)
    check(sdrCombined.toBits == [179, 595, 1288, 1333, 1500, 1557])

  test "tupleGetFirstElement":
    let sdrCombined = [179, 595, 1288, 1333, 1500, 1557].toSDR
    let sdr2 = [2,4,6].toSDR
    let first = tupleGetFirstElement(sdrCombined, sdr2)
    check(first.toBits == [1,3,5])

  test "tupleGetSecondElement":
    let sdrCombined = [179, 595, 1288, 1333, 1500, 1557].toSDR
    let sdr1 = [1,3,5].toSDR
    let second = tupleGetSecondElement(sdrCombined, sdr1)
    check(second.toBits == [2,4,6])

  test "hash":
    let sdr1 = [1,3,5].toSDR
    check(sdr1.hash == 8413795979810792752)
    let sdr2 = [0].toSDR
    check(sdr2.hash == -8984468311193396829)
    let sdr3 = toSeq(0..<2048).toSDR
    check(sdr3.hash == -1520062087236158065)