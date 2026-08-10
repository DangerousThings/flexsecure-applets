#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build vkpiv
cp /app/src/scripts/compile/res/vkpiv.build.xml $BUILD/build.xml
patch_version $BUILD/applet/src/com/vivokey/vkpiv/VkPivApplet.java
JC_HOME=/app/sdks/jc305u3_kit build_default
