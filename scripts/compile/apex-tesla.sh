#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build apex-tesla
patch_version $BUILD/src/com/vivokey/teslaIdent/TeslaIdent.java
build_default