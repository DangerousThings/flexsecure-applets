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
    cd /app/src/applets/FIDO2Applet
    java -cp /app/tools/jcardsim/target/jcardsim-3.0.5-SNAPSHOT.jar:./build/classes/java/main com.licel.jcardsim.remote.VSmartCard /app/src/scripts/test/res/FIDO2Applet.jcardsim.cfg > /dev/null &
    JCSIM_PID="$!"
    sleep 2
    PARAM="a800f50505061820071904000818200918fe0a1904000b190400"
    opensc-tool -r 'Virtual PCD 00 00' -s "80 b8 00 00 26  08  A0 00 00 06 47 2F 00 01  00  1A $PARAM FF"
    cd /app/tools/fido-attestation-loader
    ./attestation.py ca create -cap 123456
    openssl pkcs8 -in ca_key.p8 -inform DER -out ca_key_raw.p8 -outform DER -passin pass:123456
    /app/src/applets/FIDO2Applet/install_attestation_cert.py --name "Token Attestation" --aaguid "27291256273545b599f92863c9dddd72" --org "Generic" --country "US" --ca-cert-bytes "$(base64 /app/tools/fido-attestation-loader/ca.der)" --ca-private-key "$(base64 /app/tools/fido-attestation-loader/ca_key_raw.p8)"
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
