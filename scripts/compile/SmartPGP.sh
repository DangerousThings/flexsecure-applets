#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build SmartPGP
cp /app/src/scripts/compile/res/SmartPGP.build.xml $BUILD
JC_HOME=/app/sdks/jc304_kit build_default -buildfile SmartPGP.build.xml