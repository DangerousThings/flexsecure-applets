#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build javacard-memory dist
JC_HOME=/app/sdks/jc304_kit build_default
