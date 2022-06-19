#!/usr/bin/env bats

load res/common.sh

setup_file() {
    _setup_file
}

teardown_file() {
    _teardown_file
}

setup() {
    cd /app/src/applets/u2f-javacard
    java -cp /app/tools/jcardsim/target/jcardsim-3.0.5-SNAPSHOT.jar:./target com.licel.jcardsim.remote.VSmartCard /app/src/scripts/test/res/u2f-javacard.jcardsim.cfg > /dev/null &
    JCSIM_PID="$!"
    sleep 2
    opensc-tool -r 'Virtual PCD 00 00' -s '80 b8 00 00 2F  08  A0 00 00 06 47 2F 00 01  00  23  01 01 40 f3 fc cc 0d 00 d8 03 19 54 f9 08 64 d4 3c 24 7f 4b f5 f0 66 5c 6b 50 cc 17 74 9a 27 d1 cf 76 64  FF'
    opensc-tool -r 'Virtual PCD 00 00' \
        -s '00 A4 04 00 08 A0 00 00 06 47 2F 00 01' \
        -s '80 01 00 00 80 30 82 01 3c 30 81 e4 a0 03 02 01 02 02 0a 47 90 12 80 00 11 55 95 73 52 30 0a 06 08 2a 86 48 ce 3d 04 03 02 30 17 31 15 30 13 06 03 55 04 03 13 0c 47 6e 75 62 62 79 20 50 69 6c 6f 74 30 1e 17 0d 31 32 30 38 31 34 31 38 32 39 33 32 5a 17 0d 31 33 30 38 31 34 31 38 32 39 33 32 5a 30 31 31 2f 30 2d 06 03 55 04 03 13 26 50 69 6c 6f 74 47 6e 75 62 62 79 2d 30 2e 34 2e 31 2d 34 37 39 30' \
        -s '80 01 00 80 80 31 32 38 30 30 30 31 31 35 35 39 35 37 33 35 32 30 59 30 13 06 07 2a 86 48 ce 3d 02 01 06 08 2a 86 48 ce 3d 03 01 07 03 42 00 04 8d 61 7e 65 c9 50 8e 64 bc c5 67 3a c8 2a 67 99 da 3c 14 46 68 2c 25 8c 46 3f ff df 58 df d2 fa 3e 6c 37 8b 53 d7 95 c4 a4 df fb 41 99 ed d7 86 2f 23 ab af 02 03 b4 b8 91 1b a0 56 99 94 e1 01 30 0a 06 08 2a 86 48 ce 3d 04 03 02 03 47 00 30 44 02 20 60 cd' \
        -s '80 01 01 00 40 b6 06 1e 9c 22 26 2d 1a ac 1d 96 d8 c7 08 29 b2 36 65 31 dd a2 68 83 2c b8 36 bc d3 0d fa 02 20 63 1b 14 59 f0 9e 63 30 05 57 22 c8 d8 9b 7f 48 88 3b 90 89 b8 8d 60 d1 d9 79 59 02 b3 04 10 df'
}

teardown() {
    _teardown
}


@test "U2F Register and Authenticate https://demo.yubico.com/" {
    RES=`fido2-webauthn-client "pcsc://slot0" 2>&1 | sed -n -e '/http_response_json: https:\/\/demo\.yubico\.com\/api\/v1\/simple\/webauthn\/authenticate-finish/,$p' | sed 1d`
    STATUS=`echo $RES | jq -r '.status'`
    [ "$STATUS" == "success" ]
}
