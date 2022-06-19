#!/usr/bin/env bats

setup_file() {
    pcscd -f &
    PCSCD_PID="$!"
    sleep 2
}

teardown_file() {
    kill $PCSCD_PID
}

setup() {
    cd /app/src/applets/vk-ykhmac
    java -cp /app/tools/jcardsim/target/jcardsim-3.0.5-SNAPSHOT.jar:./target com.licel.jcardsim.remote.VSmartCard test/jcardsim.cfg > /dev/null &
    JCSIM_PID="$!"
    sleep 2
    opensc-tool -r 'Virtual PCD 00 00' -s '80 b8 00 00 0e  07  a0 00 00 05 27 20 01  05 00 00 02 FF  7f'
    SECRET='59fc9f75041ce4848614738a1c39bb565090ad9f'
    CHALLENGE='4e7cbb8fedc4ae11b7546f3c9986fdffeba2d9d7d1cc00799a7e5bcfb267e1bf'
    RESPONSE='4ff8aa748188a4be57f4d7eff27eccda639b289f'
}

teardown() {
    kill $JCSIM_PID
    sleep 2
}


@test "yubikey-manager program and respond" {
    cd /app/tools/yubikey-manager
    poetry run ykman -r 'Virtual PCD 00 00' otp chalresp -f 1 $SECRET
    YKMANRES=`poetry run ykman -r 'Virtual PCD 00 00' otp calculate 1 $CHALLENGE`
    [ "$YKMANRES" == "$RESPONSE" ]
}

@test "ykhmac program and respond" {
    echo $SECRET | java -jar /usr/bin/yktool.jar program hmac 1 -x -X
    YKRES=`printf $CHALLENGE | java -jar /usr/bin/yktool.jar hmac 1 -x -X`
    YKRES=${YKRES//:/}
    YKRES=${YKRES,,}
    [ "$YKRES" == "$RESPONSE" ]
}

@test "KeePassXC decrypt and read " {
    echo $SECRET | java -jar /usr/bin/yktool.jar program hmac 1 -x -X
    SERIAL=`java -jar /usr/bin/yktool.jar list | sed -r 's/.*#([0-9]*)\s.*/\1/'`
    SECRET=`echo '12345678' | keepassxc-cli show -s -a Password -y "1:$SERIAL" /app/src/scripts/test/res/vk-ykhmac.testdb.kdbx Test`
    [ "$SECRET" == "RMGG4lkT4Kd3k8FYsQ3b" ]
}
