#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build apex-ndef
JC_HOME=/app/sdks/jc305u3_kit build_default