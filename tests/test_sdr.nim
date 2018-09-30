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
    let sdr = [1,3,5].toSDR
    check(sdr.toBits == [1,3,5])

  test "minus":
    let sdr1 = [1,2].toSDR
    let sdr2 = [2].toSDR
    let sdr3 = minus(sdr1, sdr2)
    check(sdr3.toBits == [1])

  test "union":
    let sdr1 = [1].toSDR
    let sdr2 = [2].toSDR
    var sdr3 = union(sdr1, sdr2)
    check(sdr3.toBits == [1,2])

  test "intersection":
    let sdr1 = [1,2].toSDR
    let sdr2 = [2].toSDR
    var sdr3 = intersection(sdr1, sdr2)
    check(sdr3.toBits == [2])

  test "xor":
    let sdr1 = [1,2].toSDR
    let sdr2 = [2,3].toSDR
    var sdr3 = `xor`(sdr1, sdr2)
    check(sdr3.toBits == [1,3])

  test "swap":
    let sdr1 = [1,3].toSDR
    sdr1.swap(1, 2)
    check(sdr1.toBits == [2,3])

  test "copy":
    let sdr1 = [1].toSDR
    var sdr2 = sdr1.copy()
    check(sdr2.toBits == [1])

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
    check(sdrCombined.toBits == [9,19,24,29,45,60])

  test "tupleGetFirstElement":
    let sdrCombined = [9,19,24,29,45,60].toSDR
    let sdr2 = [2,4,6].toSDR
    let first = tupleGetFirstElement(sdrCombined, sdr2)
    check(first.toBits == [1,3,5])

  test "tupleGetSecondElement":
    let sdrCombined = [9,19,24,29,45,60].toSDR
    let sdr1 = [1,3,5].toSDR
    let second = tupleGetSecondElement(sdrCombined, sdr1)
    check(second.toBits == [2,4,6])
