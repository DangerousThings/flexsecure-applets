#!/usr/bin/env bash

_setup_file() {
    mkdir -p /run/pcscd
    pcscd -f --disable-polkit &
    PCSCD_PID="$!"
    sleep 4
}

_teardown_file() {
    kill $PCSCD_PID
}

_teardown() {
    kill $JCSIM_PID
    sleep 4
}