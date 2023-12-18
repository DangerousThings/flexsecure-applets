#!/usr/bin/env bash

prepare_build() {
    export BUILD=/tmp/builds/$1
    echo "Setting up build for $1 in $BUILD"
    mkdir -p /app/src/bin
    rm -rf $BUILD
    mkdir -p /tmp/builds
    cp -r /app/src/applets/$1 $BUILD
}

build_default() {
    cd $BUILD
    mkdir -p $BUILD/target
    ant $@
    cp $BUILD/target/*.cap /app/src/bin/
}
