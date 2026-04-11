#!/usr/bin/env bats

load res/common.sh

setup_file() {
    _setup_file
}

teardown_file() {
    _teardown_file
}

setup() {
    cd /tmp/builds/apex-totp
    java -cp /app/tools/jcardsim/target/jcardsim-3.0.5-SNAPSHOT.jar:./target com.licel.jcardsim.remote.VSmartCard /app/src/scripts/test/res/apex-totp.jcardsim.cfg > /dev/null &
    JCSIM_PID="$!"
    sleep 5
    AID='A0000005272101014150455801'
    # GlobalPlatform INSTALL: apex-totp (OATH applet).
    opensc-tool -r 'Virtual PCD 00 00' -s "$(_install_apdu "$AID" '00 FF')"
    sleep 3
    # Fixed base32 TOTP secret used across both tests for reproducibility.
    SECRETB32='IVCEGRTIOQ3UGSLNI5KDMT2RKF4FGUCO'
}

teardown() {
    _teardown
}


@test "version" {
    _test_version "$AID"
}

@test "ykman program TOTP and oathtool validate" {
    ykman -r 'Virtual PCD 00 00' oath accounts uri "otpauth://totp/Test?secret=$SECRETB32"
    YKRES=`ykman -r 'Virtual PCD 00 00' oath accounts code Test`
    # Strip the account name prefix ("Test  ") that ykman prepends to the OTP code.
    YKRES=${YKRES#"Test  "}
    REF=`oathtool -b --totp "$SECRETB32"`
    [ "$YKRES" == "$REF" ]
}

@test "ykman program HOTP and oathtool validate" {
    # Counter 42 is an arbitrary non-zero starting point to confirm the counter is stored and used.
    ykman -r 'Virtual PCD 00 00' oath accounts uri "otpauth://hotp/Test?secret=$SECRETB32&counter=42"
    YKRES=`ykman -r 'Virtual PCD 00 00' oath accounts code Test`
    YKRES=${YKRES#"Test  "}
    REF=`oathtool -c 42 -b --hotp "$SECRETB32"`
    [ "$YKRES" == "$REF" ]
}
