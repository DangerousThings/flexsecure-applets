[![Build Status](https://drone-github.infrastructure.vivokey.com/api/badges/DangerousThings/flexsecure-applets/status.svg)](https://drone-github.infrastructure.vivokey.com/DangerousThings/flexsecure-applets)

# flexsecure-applets

Collection of JavaCard applets for the DangerousThings FlexSecure and VivoKey Apex, as well as build and testing scripts.

For documentation, see `docs/` . Or read the forums at https://forum.dangerousthings.com/c/support/flexsecure-support/24 .

Some submodules contain private / proprietary applets and require access permissions.

## Download

Public compiled binaries are available from the GitHub releases page: https://github.com/DangerousThings/flexsecure-applets/releases .

## Development Usage

Install Docker. Use the `docker-*.sh` scripts in `scripts/` to compile and test the applets. Binaries will be placed in `bin/`. This repository also runs on a Drone CI server.

## Version Command

The build system in this repository adds an extra version APDU command to each applet. See `scripts/compile/res/version.py`. Use this build system if you want to generate release equivalent binaries.
