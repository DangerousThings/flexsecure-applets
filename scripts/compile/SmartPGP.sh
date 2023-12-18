#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build SmartPGP
cp /app/src/scripts/compile/res/SmartPGP.build.xml $BUILD/build.xml
patch_version $BUILD/src/fr/anssi/smartpgp/SmartPGPApplet.java
JC_HOME=/app/sdks/jc304_kit build_default