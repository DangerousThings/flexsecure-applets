#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build apex-totp
patch_version $BUILD/src/com/vivokey/otp/YkneoOath.java
JC_HOME=/app/sdks/jc304_kit build_default dist
