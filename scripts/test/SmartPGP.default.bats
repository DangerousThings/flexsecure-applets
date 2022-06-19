#!/usr/bin/env bats

load res/common.sh
load res/SmartPGP.common.sh

setup_file() {
    _setup_file
}

teardown_file() {
    _teardown_file
}

setup() {
    pgp_setup default
}

teardown() {
    rm -rf /app/tmp
    rm -rf ~/.gnupg
    _teardown
}


# @test "GPG generate RSA 2048 key and sign" {
#     /app/src/scripts/test/res/SmartPGP.generate.RSA2048.expect
#     KUID=`gpg --list-keys --with-colons | awk -F: '$1=="uid" {print $10; exit}'`
#     sign_verify
#     VERRET=$?
#     [ "$KUID" == "CI Test (CI Testing Key) <test@example.com>" ] && [ "$VERRET" == 0 ]
# }

# @test "GPG generate ECC NIST256 key and sign" {
#     /app/src/scripts/test/res/SmartPGP.generate.ECCNIST256.expect
#     KUID=`gpg --list-keys --with-colons | awk -F: '$1=="uid" {print $10; exit}'`
#     sign_verify
#     VERRET=$?
#     [ "$KUID" == "CI Test (CI Testing Key) <test@example.com>" ] && [ "$VERRET" == 0 ]
# }

@test "GPG import RSA 2048 key and sign" {
    gpg --batch --generate-key /app/src/scripts/test/res/SmartPGP.RSA2048.gen-key
    /app/src/scripts/test/res/SmartPGP.import.RSA2048.expect
    KUID=`gpg --list-keys --with-colons | awk -F: '$1=="uid" {print $10; exit}'`
    sign_verify
    VERRET=$?
    [ "$KUID" == "CI Test (CI Testing Key) <test@example.com>" ] && [ "$VERRET" == 0 ]
}
