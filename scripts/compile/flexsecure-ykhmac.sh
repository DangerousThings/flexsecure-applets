#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build flexsecure-ykhmac
patch_version $BUILD/src/main/java/com/vivokey/ykhmac/YkHMACApplet.java
build_default dist
