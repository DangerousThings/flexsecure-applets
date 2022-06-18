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
    mkdir -p /app/tmp
    cd /app/src/applets/SmartPGP
    java -cp /app/tools/jcardsim/target/jcardsim-3.0.5-SNAPSHOT.jar:./target com.licel.jcardsim.remote.VSmartCard /app/src/scripts/test/res/SmartPGP.jcardsim.cfg > /dev/null &
    JCSIM_PID="$!"
    sleep 2
    opensc-tool -r 'Virtual PCD 00 00' -s '80 b8 00 00 17  10  d2 76 00 01 24 01 03 04 C0 FE 00 00 00 01 00 00  05 00 00 02 FF  7f'
}

teardown() {
    rm -rf /app/tmp
    rm -rf ~/.gnupg
    kill $JCSIM_PID
    sleep 2
}


sign_verify() {
    echo "Test" > /app/tmp/secret.txt
    echo '123456' | gpg --local-user '<test@example.com>' --output /app/tmp/secret.txt.sig --passphrase-fd=0 --pinentry-mode loopback --detach-sig /app/tmp/secret.txt
    gpg --verify /app/tmp/secret.txt.sig /app/tmp/secret.txt
    return "$?"
}

@test "GPG generate key and sign" {
    /app/src/scripts/test/res/SmartPGP.generate.expect
    KUID=`gpg --list-keys --with-colons | awk -F: '$1=="uid" {print $10; exit}'`
    sign_verify
    VERRET=$?
    [ "$KUID" == "CI Test (CI Testing Key) <test@example.com>" ] && [ "$VERRET" == 0 ]
}

@test "GPG import key and sign" {
    gpg --verbose --batch --generate-key /app/src/scripts/test/res/SmartPGP.gen-key
    /app/src/scripts/test/res/SmartPGP.import.expect
    KUID=`gpg --list-keys --with-colons | awk -F: '$1=="uid" {print $10; exit}'`
    sign_verify
    VERRET=$?
    [ "$KUID" == "CI Test (CI Testing Key) <test@example.com>" ] && [ "$VERRET" == 0 ]
}
