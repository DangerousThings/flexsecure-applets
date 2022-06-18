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
    cd /app/src/applets/Flex-OTP
    java -cp /app/tools/jcardsim/target/jcardsim-3.0.5-SNAPSHOT.jar:./target com.licel.jcardsim.remote.VSmartCard /app/src/scripts/test/res/Flex-OTP.jcardsim.cfg > /dev/null &
    JCSIM_PID="$!"
    sleep 2
    opensc-tool -r 'Virtual PCD 00 00' -s '80 b8 00 00 0E  07  A0 00 00 05 27 21 01  05 00 00 02 FF  7f'
}

teardown() {
    kill $JCSIM_PID
    sleep 2
}


# @test "ykman program and validate" {
#     cd /app/tools/yubikey-manager
#     # poetry run ykman -r 'Virtual PCD 00 00' --log-level DEBUG info 
#     SECRET='EDCFht7CImGT6OQQxSPN'
#     poetry run ykman -r 'Virtual PCD 00 00' --log-level DEBUG oath accounts uri "otpauth://totp/Test?secret=$SECRET" >&3
#     # 
#     # ykman oath accounts uri "otpauth://totp/Test?secret=$SECRET" >&3
#     [ 0 ]
# }
