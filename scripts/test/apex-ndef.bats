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
    java -cp /app/tools/jcardsim/target/jcardsim-3.0.5-SNAPSHOT.jar:./target com.licel.jcardsim.remote.VSmartCard /app/src/scripts/test/res/apex-ndef.jcardsim.cfg > /dev/null &
    JCSIM_PID="$!"
    sleep 2
    CUID='f860203a257128'
    KEY='4173f37fbec4f93f3c66bb9fbf7284bf'
    opensc-tool -r 'Virtual PCD 00 00' -s "80 b8 00 00 23  07  D2760000850101  00  19  0800 $CUID $KEY FF"
}

teardown() {
    _teardown
}



cmac_setup() {
    cd /app/src/applets/apex-ndef/test
    ./cmac.py randomurl | python3 ./pcsc-ndef/pcsc_ndef.py -r "Virtual PCD 00 00" -t4 write
}

cmac_verify() {
    ./cmac.py verifyurl -k $1 -i $CUID -u $(python3 ./pcsc-ndef/pcsc_ndef.py -r "Virtual PCD 00 00" -t4 read 2>/dev/null)
    res=$?
    return $res
}


@test "NDEF check size" {
    ndef_check_size
}

@test "NDEF read write" {
    ndef_read_write
}

@test "NDEF CMAC positive" {
    cmac_setup
    cmac_verify $KEY
    cmac_verify $KEY
    cmac_verify $KEY
}

@test "NDEF CMAC negative" {
    cmac_setup
    run cmac_verify '1eedb2ff62cfe26dd58c8368d5169bdb'
    [ "$status" -eq 1 ]
}
