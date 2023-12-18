#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build u2f-javacard
cp /app/src/scripts/compile/res/u2f-javacard.build.xml $BUILD/build.xml
patch_version $BUILD/src/main/java/com/ledger/u2f/U2FApplet.java
JC_HOME=/app/sdks/jc304_kit build_default
