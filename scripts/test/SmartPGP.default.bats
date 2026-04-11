#!/usr/bin/env bats

# Tests for the SmartPGP "default" build: RSA up to 2048 bits and NIST ECC curves.
# The "large" build (SmartPGP.large.bats) extends this with RSA 3072/4096.

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
    # Remove generated keys and GPG state so tests are fully isolated.
    rm -rf /app/tmp
    rm -rf ~/.gnupg
    _teardown
}


# generate_sign: runs an expect script to generate a key on-card via gpg, then signs and verifies.
# import_sign: generates a key on the host, imports it to the card, then signs and verifies.
# algo_switch: tells the applet which algorithm to expect before an import.
# write_*_keygen: writes a gpg --batch key spec to /app/tmp/gen-key for import_sign.

@test "GPG generate RSA 2048 key and sign" {
    generate_sign RSA 2048
    [ "$?" == 0 ]
}

@test "GPG generate ECC NIST P-256 key and sign" {
    # ECC curve IDs passed to SmartPGP.generate.ECC.expect: 3=P-256, 4=P-384, 5=P-521.
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
