#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build SmartPGP
patch_version $BUILD/src/fr/anssi/smartpgp/SmartPGPApplet.java
cp /app/src/scripts/compile/res/SmartPGP.build.xml $BUILD/build.xml
JC_HOME=/app/sdks/jc304_kit build_default