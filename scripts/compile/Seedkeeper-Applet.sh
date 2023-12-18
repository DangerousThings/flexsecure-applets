#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build Seedkeeper-Applet
patch_version $BUILD/src/org/seedkeeper/applet/SeedKeeper.java
cp /app/src/scripts/compile/res/Seedkeeper-Applet.build.xml $BUILD/build.xml
JC_HOME=/app/sdks/jc304_kit build_default