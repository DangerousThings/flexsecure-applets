#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build SatochipApplet
cp /app/src/scripts/compile/res/SatochipApplet.build.xml $BUILD
JC_HOME=/app/sdks/jc304_kit build_default -buildfile SatochipApplet.build.xml