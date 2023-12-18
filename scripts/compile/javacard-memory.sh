#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build javacard-memory dist
patch_version $BUILD/src/de/chrz/jcmemory/JCMemoryApplet.java
JC_HOME=/app/sdks/jc304_kit build_default
