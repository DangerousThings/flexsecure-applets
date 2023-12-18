#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build Seedkeeper-Applet
cp /app/src/scripts/compile/res/Seedkeeper-Applet.build.xml $BUILD
JC_HOME=/app/sdks/jc304_kit build_default -buildfile Seedkeeper-Applet.build.xml