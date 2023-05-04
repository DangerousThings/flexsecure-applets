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
    cd /app/src/applets/apex-ndef
    java -cp /app/tools/jcardsim/target/jcardsim-3.0.5-SNAPSHOT.jar:./build/classes/full com.licel.jcardsim.remote.VSmartCard /app/src/scripts/test/res/apex-ndef.jcardsim.cfg > /dev/null &
    JCSIM_PID="$!"
    sleep 2
    opensc-tool -r 'Virtual PCD 00 00' -s '80 b8 00 00 13  07  D2 76 00 00 85 01 01  00  08  81 02 00 00  82 02 08 00  ff'
}

teardown() {
    _teardown
}


@test "NDEF check size" {
    ndef_check_size
}

@test "NDEF read write" {
    ndef_read_write
}
