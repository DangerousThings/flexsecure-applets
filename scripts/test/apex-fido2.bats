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
    cd /app/src/applets/apex-fido2
    java -cp /app/tools/jcardsim/target/jcardsim-3.0.5-SNAPSHOT.jar:./target com.licel.jcardsim.remote.VSmartCard /app/src/scripts/test/res/apex-fido2.jcardsim.cfg > /dev/null &
    JCSIM_PID="$!"
    sleep 2
    cd /app/tools/fido-attestation-loader
    ./attestation.py ca create -cap 123456
    ./attestation.py cert create -p 1234 -cap 123456
    PARAM=`./attestation.py cert show -p 1234 -f parameter -m fido2ci -cap 123456`
    opensc-tool -r 'Virtual PCD 00 00' -s "80 b8 00 00 3F  08  A0 00 00 06 47 2F 00 01  00  33 $PARAM FF"
    ./attestation.py cert upload -m fido2
}

teardown() {
    cd /app/tools/fido-attestation-loader
    rm -f *.der *.p8 assert_param cred* pubkey
    _teardown
}


@test "FIDO2 Register and Authenticate CTAP2-CTAP2 ES256" {
    fido_make_cred es256 hmac fido2
    fido_assert_cred es256 hmac fido2
}

@test "FIDO2 Register and Authenticate CTAP2-CTAP2 RS256" {
    fido_make_cred rs256 hmac fido2
    fido_assert_cred rs256 hmac fido2
}

@test "FIDO2 Register and Authenticate CTAP2-CTAP1" {
    fido_make_cred es256 nohmac fido2
    fido_assert_cred es256 nohmac u2f
}

@test "FIDO2 Register and Authenticate CTAP1-CTAP2" {
    fido_make_cred es256 nohmac u2f
    fido_assert_cred es256 nohmac fido2
}

@test "FIDO2 Register and Authenticate CTAP1-CTAP1" {
    fido_make_cred es256 nohmac u2f
    fido_assert_cred es256 nohmac u2f
}

#@test "FIDO2 Register and Authenticate https://demo.yubico.com/" {
#    RES=`fido2-webauthn-client "pcsc://slot0" 2>&1 | sed -n -e '/http_response_json: https:\/\/demo\.yubico\.com\/api\/v1\/simple\/webauthn\/authenticate-finish/,$p' | sed 1d`
#    STATUS=`echo $RES | jq -r '.status'`
#    [ "$STATUS" == "success" ]
#}
