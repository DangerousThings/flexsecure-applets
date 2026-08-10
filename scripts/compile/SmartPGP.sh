#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build SmartPGP
cp /app/src/scripts/compile/res/SmartPGP.build.xml $BUILD/build.xml
patch_version $BUILD/src/fr/anssi/smartpgp/SmartPGPApplet.java
JC_HOME=/app/sdks/jc304_kit build_default build-large build-default
JC_HOME=/app/sdks/jc310b43_kit build_default -Dcurve25519.jar=/app/src/bin/curve25519.jar build-default-curve25519