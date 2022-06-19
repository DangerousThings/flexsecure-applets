#!/usr/bin/env bats

setup_file() {
    pcscd -f &
    PCSCD_PID="$!"
    sleep 2
}

teardown_file() {
    kill $PCSCD_PID
}

setup() {
    cd /app/src/applets/openjavacard-ndef
    java -cp /app/tools/jcardsim/target/jcardsim-3.0.5-SNAPSHOT.jar:./build/classes/full com.licel.jcardsim.remote.VSmartCard /app/src/scripts/test/res/openjavacard-ndef.jcardsim.cfg > /dev/null &
    JCSIM_PID="$!"
    sleep 2
    opensc-tool -r 'Virtual PCD 00 00' -s '80 b8 00 00 13  07  D2 76 00 00 85 01 01  00  08  81 02 00 00  82 02 08 00  ff'
}

teardown() {
    kill $JCSIM_PID
    sleep 2
}


@test "NDEF check size" {
    cd /app/tools/pcsc-ndef
    RESP=`python3 pcsc_ndef.py -r "Virtual PCD 00 00" -t4 getmax`
    [ "$RESP" == "2046" ]
}

@test "NDEF read write" {
    cd /app/tools/pcsc-ndef
    PAYLOAD='fHwG61CGBRM3L6ZrpGpq'
    echo $PAYLOAD | python3 pcsc_ndef.py -r "Virtual PCD 00 00" -t 4 write >&3
    RESP=`python3 pcsc_ndef.py -r "Virtual PCD 00 00" -t 4 read`
    [ "$RESP" == "$PAYLOAD" ]
}
