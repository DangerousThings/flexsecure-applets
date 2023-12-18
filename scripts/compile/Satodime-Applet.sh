#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build Satodime-Applet
cp /app/src/scripts/compile/res/Satodime-Applet.build.xml $BUILD/build.xml
patch_version $BUILD/src/org/satodime/applet/Satodime.java
JC_HOME=/app/sdks/jc304_kit build_default