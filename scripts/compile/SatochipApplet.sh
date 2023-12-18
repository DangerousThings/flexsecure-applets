#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build SatochipApplet
patch_version $BUILD/src/org/satochip/applet/CardEdge.java
cp -f /app/src/scripts/compile/res/SatochipApplet.build.xml $BUILD/build.xml
JC_HOME=/app/sdks/jc304_kit build_default