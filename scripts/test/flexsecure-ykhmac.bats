#!/usr/bin/env bats

load res/common.sh

setup_file() {
    _setup_file
}

teardown_file() {
    _teardown_file
}

setup() {
    cd /tmp/builds/flexsecure-ykhmac
    java -cp /app/tools/jcardsim/target/jcardsim-3.0.5-SNAPSHOT.jar:./target com.licel.jcardsim.remote.VSmartCard /app/src/scripts/test/res/flexsecure-ykhmac.jcardsim.cfg > /dev/null &
    JCSIM_PID="$!"
    sleep 2
    # GlobalPlatform INSTALL: AID A0000005272001 01 → YubiKey HMAC-SHA1 challenge-response applet.
    opensc-tool -r 'Virtual PCD 00 00' -s '80 b8 00 00 0A  08  a0 00 00 05 27 20 01 01  00  FF'
    SECRET='59fc9f75041ce4848614738a1c39bb565090ad9f'    # 20-byte HMAC-SHA1 key (hex)
    CHALLENGE='4e7cbb8fedc4ae11b7546f3c9986fdffeba2d9d7d1cc00799a7e5bcfb267e1bf'
    RESPONSE='4ff8aa748188a4be57f4d7eff27eccda639b289f'  # Expected HMAC-SHA1(SECRET, CHALLENGE)
}

teardown() {
    _teardown
}


@test "ykman program and respond" {
    cd /app/tools/yubikey-manager
    poetry run ykman -r 'Virtual PCD 00 00' otp chalresp -f 1 $SECRET
    YKMANRES=`poetry run ykman -r 'Virtual PCD 00 00' otp calculate 1 $CHALLENGE`
    [ "$YKMANRES" == "$RESPONSE" ]
}

@test "ykhmac program and respond" {
    echo $SECRET | java -jar /usr/bin/yktool.jar program hmac 1 -x -X
    YKRES=`printf $CHALLENGE | java -jar /usr/bin/yktool.jar hmac 1 -x -X`
    # yktool outputs hex with colon separators (e.g. "4f:f8:aa:..."); strip and lowercase.
    YKRES=${YKRES//:/}
    YKRES=${YKRES,,}
    [ "$YKRES" == "$RESPONSE" ]
}

@test "KeePassXC decrypt and read " {
    # Programs slot 1 with the HMAC-SHA1 key, then uses challenge-response to unlock the test database.
    # The database is configured to require a matching HMAC-SHA1 response as a key component.
    echo $SECRET | java -jar /usr/bin/yktool.jar program hmac 1 -x -X
    SERIAL=`java -jar /usr/bin/yktool.jar list | sed -r 's/.*#([0-9]*)\s.*/\1/'`
    SECRET=`echo '12345678' | keepassxc-cli show -s -a Password -y "1:$SERIAL" /app/src/scripts/test/res/flexsecure-ykhmac.testdb.kdbx Test`
    [ "$SECRET" == "RMGG4lkT4Kd3k8FYsQ3b" ]
}
