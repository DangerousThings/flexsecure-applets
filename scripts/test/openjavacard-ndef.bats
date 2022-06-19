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
    java -cp /app/tools/jcardsim/target/jcardsim-3.0.5-SNAPSHOT.jar:./build/classes/full com.licel.jcardsim.remote.VSmartCard /app/src/scripts/test/res/openjavacard-ndef.jcardsim.cfg >&3 &
    JCSIM_PID="$!"
    sleep 2
    opensc-tool -r 'Virtual PCD 00 00' -s '80 b8 00 00 12  07  D2 76 00 00 85 01 01  09  81 02 00 00  82 02 00 80  ff'
    # opensc-tool -r 'Virtual PCD 00 00' -s '80 02 00 00 00 01' >&3
    # opensc-tool -r 'Virtual PCD 00 00' -s '00 a4 04 00  07  D2 76 00 00 85 01 01  00'
}

teardown() {
    kill $JCSIM_PID
    sleep 2
}


# @test "NDEF read write" {
#     cd /app/tools/pcsc-ndef
#     # pcsc_scan -c >&3
#     # python3 pcsc_ndef.py -r "Virtual PCD 00 00" -t4 getmax  >&3
#     # echo 'Test' | python3 pcsc_ndef.py -r "Virtual PCD 00 00" -t 4 write >&3
#     # python3 pcsc_ndef.py -r "Virtual PCD 00 00" -t 4 read >&3
#     [ 0 ]
# }
