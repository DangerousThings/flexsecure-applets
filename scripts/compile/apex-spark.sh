#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build apex-spark
patch_version $BUILD/src/com/vivokey/spark/Spark2.java
JC_HOME=/app/sdks/jc305u3_kit build_default