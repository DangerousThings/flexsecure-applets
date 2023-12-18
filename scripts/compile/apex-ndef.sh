#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build apex-ndef
patch_version $BUILD/src/main/java/com/vivokey/ndef/NDEF.java
JC_HOME=/app/sdks/jc305u3_kit build_default