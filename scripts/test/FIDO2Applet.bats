#!/usr/bin/env bats

load res/common.sh
load res/FIDO.common.sh

setup_file() {
    _setup_file
}

teardown_file() {
    _teardown_file
}

setup() {
    cd /tmp/builds/FIDO2Applet
    java -cp /app/tools/jcardsim/target/jcardsim-3.0.5-SNAPSHOT.jar:./build/classes/java/main com.licel.jcardsim.remote.VSmartCard /app/src/scripts/test/res/FIDO2Applet.jcardsim.cfg > /dev/null &
    JCSIM_PID="$!"
    sleep 5
    # fido-attestation-loader generates a self-signed CA and device certificate for the fido21 profile.
    # Certificate length varies, so ALEN (total APDU Lc) and PLEN (param field length) are computed dynamically.
    cd /app/tools/fido-attestation-loader
    ./attestation.py ca create -cap 123456
    ./attestation.py cert create -p 1234 -cap 123456 -m fido21
    AID='A0000006472F0001'
    PARAM=`./attestation.py cert show -p 1234 -f parameter -m fido21`
    PLEN=$(printf "%02x" $(( ${#PARAM} / 2 )))
    # GlobalPlatform INSTALL: FIDO2Applet (FIDO AID), install params = attestation cert bytes.
    opensc-tool -r 'Virtual PCD 00 00' -s "$(_install_apdu "$AID" "00 $PLEN $PARAM FF")"
    sleep 3
    ./attestation.py cert upload -m fido21
}

teardown() {
    cd /app/tools/fido-attestation-loader
    rm -f *.der *.p8 assert_param assert_raw cred* pubkey
    _teardown
}


# CTAP2-CTAP2: both registration and assertion use FIDO2 (with HMAC-secret extension).
@test "version" {
    _test_version "$AID"
}

@test "FIDO2 Register and Authenticate CTAP2-CTAP2 ES256" {
    fido_make_cred es256 hmac fido2
    fido_assert_cred es256 hmac fido2
}

# Cross-protocol: registration via CTAP2, assertion via U2F (CTAP1 backwards compat).
@test "FIDO2 Register and Authenticate CTAP2-CTAP1" {
    fido_make_cred es256 nohmac fido2
    fido_assert_cred es256 nohmac u2f
}

# Cross-protocol: registration via U2F, assertion via CTAP2 (forward compat).
@test "FIDO2 Register and Authenticate CTAP1-CTAP2" {
    fido_make_cred es256 nohmac u2f
    fido_assert_cred es256 nohmac fido2
}

@test "FIDO2 Register and Authenticate CTAP1-CTAP1" {
    fido_make_cred es256 nohmac u2f
    fido_assert_cred es256 nohmac u2f
}

@test "FIDO2 Discoverable Credential Lifecycle" {
    # Full passkey (resident key) lifecycle: set PIN → create → assert → list RP → delete → assert fails.
    # fido2-token operations require a PIN and use setsid for TTY-based PIN entry.
    fido_set_pin
    fido_make_resident_cred es256
    fido_assert_resident_cred es256
    fido_token_list_rps | grep -q "$FIDO_RP"
    fido_delete_resident_cred
    run fido_attempt_assert_resident_cred es256
    [ "$status" -ne 0 ]
}

#@test "FIDO2 Register and Authenticate https://demo.yubico.com/" {
#    RES=`fido2-webauthn-client "pcsc://slot0" 2>&1 | sed -n -e '/http_response_json: https:\/\/demo\.yubico\.com\/api\/v1\/simple\/webauthn\/authenticate-finish/,$p' | sed 1d`
#    STATUS=`echo $RES | jq -r '.status'`
#    [ "$STATUS" == "success" ]
#}
