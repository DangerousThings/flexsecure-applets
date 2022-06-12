#!/usr/bin/env bats

setup_file() {
    pcscd -f &
    PCSCD_PID=$!
    sleep 1
}

teardown_file() {
    kill $PCSCD_PID
}

setup() {
    cd /app/src/applets/SmartPGP
    java -cp /app/tools/jcardsim/target/jcardsim-3.0.5-SNAPSHOT.jar:./target com.licel.jcardsim.remote.VSmartCard /app/src/scripts/test/res/SmartPGP.jcardsim.cfg > /dev/null &
    JCSIM_PID=$!
    sleep 1
    opensc-tool -r 'Virtual PCD 00 00' -s '80 b8 00 00 17  10  d2 76 00 01 24 01 03 04 C0 FE 00 00 00 01 00 00  05 00 00 02 F F  7f'
}

teardown() {
    kill $JCSIM_PID
}

@test "GPG Usage" {
    gpg --card-status >&3
    /app/src/scripts/test/res/SmartPGP.gpg.expect >&3
    gpg --card-status >&3
}

