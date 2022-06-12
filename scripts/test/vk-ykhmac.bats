#!/usr/bin/env bats

setup_file() {
    pcscd -f &
    PCSCD_PID=$!
    sleep 1
}

teardown_file() {
    kill $PCSCD_PID
}

setup() {
    cd /app/src/applets/vk-ykhmac
    java -cp /app/tools/jcardsim/target/jcardsim-3.0.5-SNAPSHOT.jar:./target com.licel.jcardsim.remote.VSmartCard test/jcardsim.cfg > /dev/null &
    JCSIM_PID=$!
    sleep 1
    opensc-tool -r 'Virtual PCD 00 00' -s '80 b8 00 00 0e  07  a0 00 00 05 27 20 01  05 00 00 02 F F  7f'
}

teardown() {
    kill $JCSIM_PID
}


program_secret() {
    echo 'b6e3f555562c894b7af13b1db37f28deff3ea89b' | java -jar /usr/bin/yktool.jar program hmac 1 -x -X
}


@test "HMAC-SHA1 using ykhmac" {
    program_secret
    YKRES=`printf 'aaaa' | java -jar /usr/bin/yktool.jar hmac 1 -x`
    [ "$YKRES" == "72:7E:C8:E8:15:EE:C5:32:8F:9D:9C:BE:5E:F2:4E:A8:36:D7:CE:56" ]
}

@test "Decrypt KeePassXC" {
    program_secret
    [ 0 ]
}
