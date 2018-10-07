import options

import concepts
import encoder
import event
import memory
import sdr

when isMainModule:
  echo "ANSNA"

  let mySDR = encodeTerm("a")
  echo $mySDR

  var mem = initMemory()
  # first test for concept
  let sdrB = encodeTerm("b")
  let conceptB = initConcept(sdrB)
  echo conceptB
  mem.addConcept(conceptB)

  let eventB = initEvent(sdrB)
  let closestExact = mem.findClosestConceptExhaustive(eventB)
  echo "closestExact: ", closestExact.get()

  let closestVoting = mem.findClosestConcepByVoting(eventB)
  echo "closestVoting: ", closestVoting.get()

  # numeric encoder test
  let w = 40
  let sdrForNumber = encodeScalar(SDR_size, w, 0, 64, 30)

  echo "SDR for number 30:"
  echo $sdrForNumber
