#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build apex-fido2
patch_version $BUILD/src/main/java/com/vivokey/fido2/Dispatcher.java
JC_HOME=/app/sdks/jc305u3_kit build_default