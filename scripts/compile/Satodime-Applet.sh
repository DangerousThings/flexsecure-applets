#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build Satodime-Applet
cp /app/src/scripts/compile/res/Satodime-Applet.build.xml $BUILD
JC_HOME=/app/sdks/jc304_kit build_default -buildfile Satodime-Applet.build.xml