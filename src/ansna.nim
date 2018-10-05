import options

import concepts
import encoder
import memory
import sdr

when isMainModule:
  echo "ANSNA"

  let mySDR = encodeTerm("a")
  echo $mySDR

  var mem = initMemory()
  # first test for concept
  let conceptAName = encodeTerm("b")
  let conceptA = initConcept(conceptAName)
  mem.addConcept(conceptA)
  echo conceptA

  let closest = mem.findClosestConceptByNameExhaustive(conceptAName)
  echo closest.get()

  # numeric encoder test
  let w = 40
  let sdrForNumber = encodeScalar(SDR_size, w, 0, 64, 30)

  echo "SDR for number 30:"
  echo $sdrForNumber
