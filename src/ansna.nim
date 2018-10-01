import options

import concepts
import encoder
import memory
import sdr

when isMainModule:
  echo "ANSNA"

  let mySDR = encodeTerm(1)
  echo $mySDR

  var mem = initMemory()
  # first test for concept
  let conceptAName = encodeTerm(2)
  let conceptA = initConcept(conceptAName)
  mem.addConcept(conceptA)

  let closest = mem.findClosestConceptByNameExhaustive(conceptAName)
  echo closest.get()


