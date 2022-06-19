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

generate_sign() {
    /app/src/scripts/test/res/SmartPGP.generate.$1.expect $2
    KUID=`gpg --list-keys --with-colons | awk -F: '$1=="uid" {print $10; exit}'`
    sign_verify
    VERRET=$?
    if [ "$KUID" == "CI Test (CI Testing Key) <test@example.com>" ] && [ "$VERRET" == 0 ]; then return 0; else return 1; fi
}

write_rsa_keygen() {
    cat >/app/tmp/gen-key <<EOF
Key-Type: RSA
Key-Length: $1
Subkey-Type: RSA
Subkey-Length: $1
Name-Real: CI Test
Name-Comment: CI Testing Key
Name-Email: test@example.com
Expire-Date: 10y
Passphrase: 123456
%commit
EOF
}

write_ecc_keygen() {
    cat >/app/tmp/gen-key <<EOF
Key-Type: ECDSA
Key-Curve: $1
Subkey-Type: ECDH
Subkey-Curve: $1
Name-Real: CI Test
Name-Comment: CI Testing Key
Name-Email: test@example.com
Expire-Date: 10y
Passphrase: 123456
%commit
EOF
}

import_sign() {
    gpg --batch --generate-key /app/tmp/gen-key
    /app/src/scripts/test/res/SmartPGP.import.$1.expect
    KUID=`gpg --list-keys --with-colons | awk -F: '$1=="uid" {print $10; exit}'`
    sign_verify
    VERRET=$?
    if [ "$KUID" == "CI Test (CI Testing Key) <test@example.com>" ] && [ "$VERRET" == 0 ]; then return 0; else return 1; fi
}
