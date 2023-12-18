#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build apex-fido2
JC_HOME=/app/sdks/jc305u3_kit build_default