#!/usr/bin/env bash

prepare_build() {
    export BUILD=/tmp/builds/$1
    echo "Setting up build for $1 in $BUILD"
    mkdir -p /app/src/bin
    rm -rf $BUILD
    mkdir -p /tmp/builds
    cp -r /app/src/applets/$1 $BUILD
}

patch_version() {
    SRC="$BUILD/build.xml"
    if [ ! -f $SRC ]; then
        SRC="$BUILD/build.gradle"
    fi
    /app/src/scripts/compile/res/version.py -s $SRC -p $1 -v $DRONE_TAG
}

build_default() {
    cd $BUILD
    mkdir -p $BUILD/target
    ant $@
    cp $BUILD/target/*.cap /app/src/bin/
}
