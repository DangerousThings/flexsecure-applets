#!/usr/bin/env bats

load res/common.sh

setup_file() {
    _setup_file
}

teardown_file() {
    _teardown_file
}

setup() {
    AID='A000000308000010000100'
    READER='Virtual PCD 00 00'
    cd /tmp/builds/vkpiv
    java -cp /app/tools/jcardsim/target/jcardsim-3.0.5-SNAPSHOT.jar:./target \
        com.licel.jcardsim.remote.VSmartCard \
        /app/src/scripts/test/res/vkpiv.jcardsim.cfg > /dev/null &
    JCSIM_PID="$!"
    sleep 5
    opensc-tool -r "$READER" -s "$(_install_apdu "$AID" '00 00 FF')"
    sleep 3
}

teardown() {
    _teardown
}


@test "version" {
    _test_version "$AID"
}

@test "PIV status reports version 5.4.0" {
    yubico-piv-tool -r "$READER" -a status 2>&1 | grep -q 'Version:.*5\.4\.0'
}

@test "PIV VERIFY with default PIN succeeds" {
    yubico-piv-tool -r "$READER" -a verify-pin -P 123456
}

@test "PIV change PIN to same value succeeds" {
    yubico-piv-tool -r "$READER" -a change-pin -P 123456 -N 123456
}

# CHUID/CCC/KeyHistory auto-gen, 9B mutual auth, PUT/GET DATA,
# GET METADATA, GET VERSION/SERIAL, hardening, Printed Info PIN-gate, PIN block + RESET.
@test "VkPivSimTest: jCardsim in-process regression suite" {
    cd /tmp/builds/vkpiv
    javac -cp /app/tools/jcardsim/target/jcardsim-3.0.5-SNAPSHOT.jar:./target \
        -d ./target \
        /app/src/applets/vkpiv/applet/test/com/vivokey/vkpiv/VkPivSimTest.java
    java -cp /app/tools/jcardsim/target/jcardsim-3.0.5-SNAPSHOT.jar:./target \
        com.vivokey.vkpiv.VkPivSimTest
}

# Certificate lifecycle via openssl keygen -> openssl self-signed cert -> import-key
# -> import-certificate -> read-certificate -> openssl verify subject
@test "certificate lifecycle: import key+cert, read back, verify subject" {
    local MGMT_KEY='010203040506070801020304050607080102030405060708'
    local KEY=/tmp/vkpiv-test-key.pem
    local CERT=/tmp/vkpiv-test-cert.pem
    # Generate EC P-256 keypair and self-signed cert on the host
    openssl ecparam -name prime256v1 -genkey -noout -out "$KEY"
    openssl req -new -x509 -key "$KEY" -out "$CERT" -days 365 -subj '/CN=vkpiv-test/'
    # Import private key into slot 9a (requires 9B management key auth)
    yubico-piv-tool -r "$READER" --key="$MGMT_KEY" -a import-key -s 9a -i "$KEY"
    # Import matching certificate into slot 9a
    yubico-piv-tool -r "$READER" --key="$MGMT_KEY" -a import-certificate -s 9a -i "$CERT"
    # Read cert back from card and verify subject round-trips correctly
    yubico-piv-tool -r "$READER" -a read-certificate -s 9a | \
        openssl x509 -noout -subject | grep -q 'vkpiv-test'
}

# OpenSC PKCS#15: card is recognized as PIV and the imported cert is listed
@test "pkcs15-tool lists certificate after import" {
    local MGMT_KEY='010203040506070801020304050607080102030405060708'
    local KEY=/tmp/vkpiv-test-key.pem
    local CERT=/tmp/vkpiv-test-cert.pem
    openssl ecparam -name prime256v1 -genkey -noout -out "$KEY"
    openssl req -new -x509 -key "$KEY" -out "$CERT" -days 365 -subj '/CN=vkpiv-test/'
    yubico-piv-tool -r "$READER" --key="$MGMT_KEY" -a import-key -s 9a -i "$KEY"
    yubico-piv-tool -r "$READER" --key="$MGMT_KEY" -a import-certificate -s 9a -i "$CERT"
    pkcs15-tool -r "$READER" --list-certificates 2>&1 | grep -qi 'certificate'
}
