[![Build Status](https://drone-github.chrz.de/api/badges/DangerousThings/flexsecure-applets/status.svg)](https://drone-github.chrz.de/DangerousThings/flexsecure-applets)

# flexsecure-applets

Collection of JavaCard applets for the DangerousThings FlexSecure and VivoKey Apex, as well as build and testing scripts.

For documentation, see `docs/` . Or read the forums at https://forum.dangerousthings.com/c/support/flexsecure-support/24 .

Some submodules contain private / proprietary applets and require access permissions.

## Download

Public compiled binaries are available from the GitHub releases page: https://github.com/DangerousThings/flexsecure-applets/releases .

## Development Usage

Install Docker. Use the `docker-*.sh` scripts in `scripts/` to compile and test the applets. Binaries will be placed in `bin/`. This repository also runs on a Drone CI server.
