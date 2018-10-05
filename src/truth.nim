import math

type
  Truth* = object
    frequency*: float
    confidence*: float

const EVIDENTAL_HORIZON = 1.0
const PROJECTION_DECAY = 0.99

proc t_and(a: float, b: float): float =
  result = a * b

# proc t_or(a: float, b: float): float =
#   result = 1 - ((1 - a) * (1 - b))

proc w2c*(w: float): float =
  result = w / (w + EVIDENTAL_HORIZON)

proc c2w*(c: float): float =
  result = EVIDENTAL_HORIZON * c / (1 - c)

proc expectation*(v: Truth): float =
  result = (v.confidence * (v.frequency - 0.5) + 0.5)

proc revision*(v1: Truth, v2: Truth): Truth =
  let w1 = c2w(v1.confidence)
  let w2 = c2w(v2.confidence)
  let w = w1 + w2
  let f = (w1 * v1.frequency + w2 * v2.frequency) / w
  let c = w2c(w)
  result = Truth(frequency: f, confidence: c)

proc deduction*(v1: Truth, v2: Truth): Truth =
  let f = t_and(v1.frequency, v2.frequency)
  let c = t_and(t_and(v1.confidence, v2.confidence), f)
  result = Truth(frequency: f, confidence: c)

proc abduction*(v1: Truth, v2: Truth): Truth =
  let w = t_and(v2.frequency, t_and(v1.confidence, v2.confidence))
  let c = w2c(w)
  result = Truth(frequency: v1.frequency, confidence: c)

proc induction*(v1: Truth, v2: Truth): Truth =
  result = abduction(v2, v1)

proc intersection*(v1: Truth, v2: Truth): Truth =
  let f = t_and(v1.frequency, v2.frequency)
  let c = t_and(v1.confidence, v2.confidence)
  result = Truth(frequency: f, confidence: c)

proc eternalize*(v: Truth): Truth =
  result = Truth(frequency: v.frequency, confidence: w2c(v.confidence))

proc projection*(v: Truth, originalTime: int64, targetTime: int64): Truth =
  let difference = abs(targetTime - originalTime)
  result = Truth(frequency: v.frequency, confidence: v.confidence * pow(PROJECTION_DECAY, float(difference)))
