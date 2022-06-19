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
    cd /app/src/applets/Flex-OTP
    java -cp /app/tools/jcardsim/target/jcardsim-3.0.5-SNAPSHOT.jar:./target com.licel.jcardsim.remote.VSmartCard /app/src/scripts/test/res/Flex-OTP.jcardsim.cfg > /dev/null &
    JCSIM_PID="$!"
    sleep 2
    opensc-tool -r 'Virtual PCD 00 00' -s '80 b8 00 00 0F  08  A0 00 00 05 27 21 01 01  05 00 00 02 FF  7f'
}

teardown() {
    kill $JCSIM_PID
    sleep 2
}


@test "yubikey-manager program and oathtool validate" {
    cd /app/tools/yubikey-manager
    SECRETB32='IVCEGRTIOQ3UGSLNI5KDMT2RKF4FGUCO'
    poetry run ykman -r 'Virtual PCD 00 00' oath accounts uri "otpauth://totp/Test?secret=$SECRETB32"
    YKRES=`poetry run ykman -r 'Virtual PCD 00 00' oath accounts code Test`
    YKRES=${YKRES#"Test  "}
    REF=`oathtool -b --totp "$SECRETB32"`
    [ "$YKRES" == "$REF" ]
}
