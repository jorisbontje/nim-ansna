type
  Usage* = object
    useCount: int
    lastUsed: int64

func usefulness*(usage: Usage, currentTime: int64): float =
  let age = currentTime - usage.lastUsed;
  let usefulnessToNormalize = float(usage.useCount) / float(age);
  result = usefulnessToNormalize / (usefulnessToNormalize + 1.0);
