#!/usr/bin/env bats

load res/common.sh

setup_file() {
    _setup_file
}

teardown_file() {
    _teardown_file
}

setup() {
    cd /app/src/applets/apex-totp
    java -cp /app/tools/jcardsim/target/jcardsim-3.0.5-SNAPSHOT.jar:./target com.licel.jcardsim.remote.VSmartCard /app/src/scripts/test/res/apex-totp.jcardsim.cfg > /dev/null &
    JCSIM_PID="$!"
    sleep 2
    opensc-tool -r 'Virtual PCD 00 00' -s '80 b8 00 00 0B  09  A0 00 00 05 27 21 01 01 02  00  FF'
    SECRETB32='IVCEGRTIOQ3UGSLNI5KDMT2RKF4FGUCO'
}

teardown() {
    _teardown
}


@test "ykman program TOTP and oathtool validate" {
    cd /app/tools/yubikey-manager
    poetry run ykman -r 'Virtual PCD 00 00' oath accounts uri "otpauth://totp/Test?secret=$SECRETB32"
    YKRES=`poetry run ykman -r 'Virtual PCD 00 00' oath accounts code Test`
    YKRES=${YKRES#"Test  "}
    REF=`oathtool -b --totp "$SECRETB32"`
    [ "$YKRES" == "$REF" ]
}

@test "ykman program HOTP and oathtool validate" {
    cd /app/tools/yubikey-manager
    poetry run ykman -r 'Virtual PCD 00 00' oath accounts uri "otpauth://hotp/Test?secret=$SECRETB32&counter=42"
    YKRES=`poetry run ykman -r 'Virtual PCD 00 00' oath accounts code Test`
    YKRES=${YKRES#"Test  "}
    REF=`oathtool -c 42 -b --hotp "$SECRETB32"`
    [ "$YKRES" == "$REF" ]
}
