#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build SatochipApplet
cp -f /app/src/scripts/compile/res/SatochipApplet.build.xml $BUILD/build.xml
patch_version $BUILD/src/org/satochip/applet/CardEdge.java
JC_HOME=/app/sdks/jc304_kit build_default