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
    sleep 2
    # GlobalPlatform INSTALL: AID D276000085010 1 (NDEF Type 4 Tag application).
    # Install params: tag 81 max-read=0x0000 (unlimited), tag 82 max-write=0x0800 (2 kB).
    opensc-tool -r 'Virtual PCD 00 00' -s '80 b8 00 00 13  07  D2 76 00 00 85 01 01  00  08  81 02 00 00  82 02 08 00  ff'
}

teardown() {
    _teardown
}


@test "NDEF check size" {
    # Verifies the applet reports the expected maximum NDEF record size (2046 bytes).
    ndef_check_size
}

@test "NDEF read write" {
    ndef_read_write
}
