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
    cd /tmp/builds/u2f-javacard
    java -cp /app/tools/jcardsim/target/jcardsim-3.0.5-SNAPSHOT.jar:./target com.licel.jcardsim.remote.VSmartCard /app/src/scripts/test/res/u2f-javacard.jcardsim.cfg > /dev/null &
    JCSIM_PID="$!"
    sleep 5
    # fido-attestation-loader generates a self-signed CA and a device certificate.
    # The certificate bytes are passed as install parameters in the INSTALL APDU so the
    # applet can include a valid attestation statement in registration responses.
    cd /app/tools/fido-attestation-loader
    ./attestation.py ca create -cap 123456
    ./attestation.py cert create -p 1234 -cap 123456
    AID='A0000006472F0001'
    PARAM=`./attestation.py cert show -p 1234 -f parameter -m u2fci`
    PLEN=$(printf "%02x" $(( ${#PARAM} / 2 )))
    # GlobalPlatform INSTALL: u2f-javacard (FIDO U2F AID), install params = attestation cert bytes.
    opensc-tool -r 'Virtual PCD 00 00' -s "$(_install_apdu "$AID" "00 $PLEN $PARAM FF")"
    sleep 3
    ./attestation.py cert upload -m u2fci
}

teardown() {
    cd /app/tools/fido-attestation-loader
    rm -f *.der *.p8 assert_param cred* pubkey
    _teardown
}


# U2F (CTAP1) only supports ES256; cross-protocol tests use u2f for registration or assertion.
@test "version" {
    _test_version "$AID"
}

@test "U2F Register and Authenticate CTAP1-CTAP1" {
    fido_make_cred es256 nohmac u2f
    fido_assert_cred es256 nohmac u2f
}

#@test "U2F Register and Authenticate https://demo.yubico.com/" {
#    RES=`fido2-webauthn-client "pcsc://slot0" 2>&1 | sed -n -e '/http_response_json: https:\/\/demo\.yubico\.com\/api\/v1\/simple\/webauthn\/authenticate-finish/,$p' | sed 1d`
#    STATUS=`echo $RES | jq -r '.status'`
#    [ "$STATUS" == "success" ]
#}
