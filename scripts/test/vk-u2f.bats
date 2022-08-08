#!/usr/bin/env bats

load res/common.sh

setup_file() {
    _setup_file
}

teardown_file() {
    _teardown_file
}

setup() {
    cd /app/src/applets/vk-u2f
    java -cp /app/src/jcardsim/target/jcardsim-3.0.5-SNAPSHOT.jar:./target com.licel.jcardsim.remote.VSmartCard /app/src/scripts/test/res/vk-u2f.jcardsim.cfg 1>&3 2>&3  & # > /dev/null &
    JCSIM_PID="$!"
    sleep 2
    cd /app/tools/fido-attestation-loader
    ./attestation.py ca create -cap 123456
    ./attestation.py cert create -p 1234 -cap 123456
    PARAM=`./attestation.py cert show -ao -p 1234 -m fido2`
    # opensc-tool -r 'Virtual PCD 00 00' -s "80 b8 00 00 3F  08  A0 00 00 06 47 2F 00 01  00  33 $PARAM FF" 1>&3 2>&3
    # ./attestation.py cert upload -m fido2
}

teardown() {
    _teardown
}


#@test "U2F Register and Authenticate https://demo.yubico.com/" {
#    RES=`fido2-webauthn-client "pcsc://slot0" 2>&1 | sed -n -e '/http_response_json: https:\/\/demo\.yubico\.com\/api\/v1\/simple\/webauthn\/authenticate-finish/,$p' | sed 1d`
#    STATUS=`echo $RES | jq -r '.status'`
#    [ "$STATUS" == "success" ]
#}
