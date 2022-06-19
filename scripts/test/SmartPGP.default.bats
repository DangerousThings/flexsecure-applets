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
    generate_sign RSA.default 2048
    [ "$?" == 0 ]
}

@test "GPG generate ECC NIST256 key and sign" {
    generate_sign ECC 3
    [ "$?" == 0 ]
}

@test "GPG generate ECC NIST384 key and sign" {
    generate_sign ECC 4
    [ "$?" == 0 ]
}

# @test "GPG generate ECC NIST521 key and sign" {
#     generate_sign ECC 5
#     [ "$?" == 0 ]
# }

@test "GPG import RSA 2048 key and sign" {
    write_rsa_keygen 2048
    import_sign RSA.default
    [ "$?" == 0 ]
}

# @test "GPG import ECC NIST256 key and sign" {
#     write_ecc_keygen nistp256
#     import_sign ECC
#     [ "$?" == 0 ]
# }

# @test "GPG import ECC NIST384 key and sign" {
#     write_ecc_keygen nistp384
#     import_sign ECC
#     [ "$?" == 0 ]
# }

# @test "GPG import ECC NIST521 key and sign" {
#     write_ecc_keygen nistp521
#     import_sign ECC
#     [ "$?" == 0 ]
# }