#!/usr/bin/env bash

_setup_file() {
    pcscd -f &
    PCSCD_PID="$!"
    sleep 2
}

_teardown_file() {
    kill $PCSCD_PID
}

_teardown() {
    kill $JCSIM_PID
    sleep 2
}