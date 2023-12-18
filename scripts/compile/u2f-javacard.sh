#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build u2f-javacard
cp /app/src/scripts/compile/res/u2f-javacard.build.xml $BUILD
JC_HOME=/app/sdks/jc304_kit build_default -buildfile u2f-javacard.build.xml
