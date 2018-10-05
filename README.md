# Adaptive Neuro-Symbolic Network Agent

[![CircleCI](https://circleci.com/gh/jorisbontje/nim-ansna.svg?style=svg)](https://circleci.com/gh/jorisbontje/nim-ansna)
[![License: Apache](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
![Stability: experimental](https://img.shields.io/badge/stability-experimental-orange.svg)

Join the NARS community:
[![Riot: #nars](https://img.shields.io/badge/riot-%23nars%3Amatrix.org-orange.svg)](https://riot.im/app/#/room/#nars:matrix.org)
[![Forum: open-nars](https://img.shields.io/badge/forum-open--nars-green.svg)](https://groups.google.com/forum/#!forum/open-nars)

## Rationale
NIM port of ANSNA (Adaptive Neuro-Symbolic Network Agent): https://github.com/patham9/ANSNA

## Building & Testing

### Prerequisites

* A recent version of Nim
  * We use version 0.19 of https://nim-lang.org/
  * Follow the Nim installation instructions or use [choosenim](https://github.com/dom96/choosenim) to manage your Nim versions

### Build & Install

We use [Nimble](https://github.com/nim-lang/nimble) to manage dependencies and run tests.

To build and install ANSNA in your home folder, just execute:

```bash
nimble install
```

After a succesful installation, running `ansna` will start the agent.

To execute all tests:
```bash
nimble test
```


## License

Licensed under both of the following:

 * Apache License, Version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
 * MIT license: [LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT
