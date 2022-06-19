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


@test "GPG generate RSA 2048 key and sign" {
    generate_sign RSA 2048
    [ "$?" == 0 ]
}

@test "GPG generate ECC NIST P-256 key and sign" {
    generate_sign ECC 3
    [ "$?" == 0 ]
}

@test "GPG generate ECC NIST P-384 key and sign" {
    generate_sign ECC 4
    [ "$?" == 0 ]
}

@test "GPG generate ECC NIST P-521 key and sign" {
    generate_sign ECC 5
    [ "$?" == 0 ]
}

@test "GPG import RSA 2048 key and sign" {
    algo_switch rsa2048
    write_rsa_keygen 2048
    import_sign
    [ "$?" == 0 ]
}

@test "GPG import ECC NIST P-256 key and sign" {
    algo_switch p256
    write_ecc_keygen nistp256
    import_sign
    [ "$?" == 0 ]
}

@test "GPG import ECC NIST P-384 key and sign" {
    algo_switch p384
    write_ecc_keygen nistp384
    import_sign
    [ "$?" == 0 ]
}

@test "GPG import ECC NIST P-521 key and sign" {
    algo_switch p521
    write_ecc_keygen nistp521
    import_sign
    [ "$?" == 0 ]
}
