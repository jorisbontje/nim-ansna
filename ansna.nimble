# Package

version       = "0.1.0"
author        = "Joris Bontje"
description   = "Adaptive Neuro-Symbolic Network Agent"
license       = "MIT"
srcDir        = "src"
bin           = @["ansna"]
skipDirs      = @["tests", "benchmarks"]


# Dependencies

requires "nim >= 0.19.0"
requires "bitarray >= 0.5.0"
