#!/usr/bin/env bash

pgp_setup() {
    mkdir -p /app/tmp
    cd /app/src/applets/SmartPGP
    java -cp /app/tools/jcardsim/target/jcardsim-3.0.5-SNAPSHOT.jar:./target/$1 com.licel.jcardsim.remote.VSmartCard /app/src/scripts/test/res/SmartPGP.jcardsim.cfg > /dev/null &
    JCSIM_PID="$!"
    sleep 2
    opensc-tool -r 'Virtual PCD 00 00' -s '80 b8 00 00 13  10  d2 76 00 01 24 01 03 04 C0 FE 00 00 00 01 00 00  00  FF'
}

sign_verify() {
    echo "Test" > /app/tmp/secret.txt
    echo '123456' | gpg --local-user '<test@example.com>' --output /app/tmp/secret.txt.sig --passphrase-fd=0 --pinentry-mode loopback --detach-sig /app/tmp/secret.txt
    gpg --verify /app/tmp/secret.txt.sig /app/tmp/secret.txt
    return "$?"
}
