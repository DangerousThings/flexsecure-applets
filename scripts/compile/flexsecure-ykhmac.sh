#!/bin/bash

source "${0%/*}/res/compile.sh"

prepare_build flexsecure-ykhmac
build_default dist
