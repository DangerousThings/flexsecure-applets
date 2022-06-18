[![Build Status](https://drone-github.chrz.de/api/badges/StarGate01/flexsecure-applets/status.svg)](https://drone-github.chrz.de/StarGate01/flexsecure-applets)

# flexsecure-applets

Collection of JavaCard applets for the FlexSecure, as well as build and testing scripts.

For documentation, see https://github.com/StarGate01/flexsecure-docs .

## Usage

Install Docker. Use the `docker-*.sh` scripts in `scripts/` to compile and test the applets. Binaries will be placed in `bin/`.

Or run it on your Drone CI.

## Project Status

- [x] Compilation in CI
- [ ] Tests in CI
  - [x] PGP
  - [ ] TOTP
  - [x] HMAC-SHA1
  - [ ] NDEF
