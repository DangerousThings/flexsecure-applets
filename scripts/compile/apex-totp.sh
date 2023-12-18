#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build apex-totp
JC_HOME=/app/sdks/jc304_kit build_default dist
