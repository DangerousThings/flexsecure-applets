#!/usr/bin/env bats

load res/common.sh

setup_file() {
    _setup_file
}

teardown_file() {
    _teardown_file
}

setup() {
    AID='A000000308000010000100'
    READER='Virtual PCD 00 00'
    cd /tmp/builds/vkpiv
    java -cp /app/tools/jcardsim/target/jcardsim-3.0.5-SNAPSHOT.jar:./target \
        com.licel.jcardsim.remote.VSmartCard \
        /app/src/scripts/test/res/vkpiv.jcardsim.cfg > /dev/null &
    JCSIM_PID="$!"
    sleep 5
    opensc-tool -r "$READER" -s "$(_install_apdu "$AID" '00 00 FF')"
    sleep 3
}

teardown() {
    _teardown
}

@test "version" {
    _test_version "$AID"
}

@test "PIV status reports version 5.4.0" {
    yubico-piv-tool -r "$READER" -a status 2>&1 | grep -q 'Version:.*5\.4\.0'
}

@test "PIV VERIFY with default PIN succeeds" {
    yubico-piv-tool -r "$READER" -a verify-pin -P 123456
}

@test "PIV change PIN to same value succeeds" {
    yubico-piv-tool -r "$READER" -a change-pin -P 123456 -N 123456
}
