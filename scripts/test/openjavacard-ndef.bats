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
    opensc-tool -r 'Virtual PCD 00 00' -s '80 b8 00 00 17  0C  D2 76 00 01 77 10 02 11 01 00 01 01  09  81 02 00 00  82 02 08 00  7f'
}

teardown() {
    kill $JCSIM_PID
    sleep 2
}


# @test "NDEF read write" {
#     cd /app/tools/pcsc-ndef
#     echo 'Test' | python3 pcsc_ndef.py -r "Virtual" -t 4 write >&3
#     python3 pcsc_ndef.py -r "Virtual" -t 4 read >&3
#     [ 0 ]
# }
