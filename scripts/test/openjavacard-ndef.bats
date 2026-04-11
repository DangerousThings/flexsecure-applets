#!/usr/bin/env bats

load res/common.sh
load res/NDEF.common.sh

setup_file() {
    _setup_file
}

teardown_file() {
    _teardown_file
}

setup() {
    cd /tmp/builds/openjavacard-ndef
    java -cp /app/tools/jcardsim/target/jcardsim-3.0.5-SNAPSHOT.jar:./build/classes/full com.licel.jcardsim.remote.VSmartCard /app/src/scripts/test/res/openjavacard-ndef.jcardsim.cfg > /dev/null &
    JCSIM_PID="$!"
    sleep 5
    AID='D2760000850101'
    # GlobalPlatform INSTALL: openjavacard-ndef (NDEF Type 4 Tag).
    # Install params: tag 81 max-read=0x0000 (unlimited), tag 82 max-write=0x0800 (2 kB).
    opensc-tool -r 'Virtual PCD 00 00' -s "$(_install_apdu "$AID" '00 08 81 02 00 00 82 02 08 00 FF')"
    sleep 3
}

teardown() {
    _teardown
}


@test "version" {
    _test_version "$AID"
}

@test "NDEF check size" {
    # Verifies the applet reports the expected maximum NDEF record size (2046 bytes).
    ndef_check_size
}

@test "NDEF read write" {
    ndef_read_write
}
