#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build Curve25519-Source
cd $BUILD
ant dist
cp $BUILD/Curve25519.cap /app/src/bin/
cp $BUILD/export_full/curve25519.jar /app/src/bin/
