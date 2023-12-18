#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build Satodime-Applet
patch_version $BUILD/src/org/satodime/applet/Satodime.java
cp /app/src/scripts/compile/res/Satodime-Applet.build.xml $BUILD/build.xml
JC_HOME=/app/sdks/jc304_kit build_default