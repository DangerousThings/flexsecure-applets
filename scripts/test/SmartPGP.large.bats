#!/usr/bin/env bats

# Tests for the SmartPGP "large" build: RSA 3072 and 4096.
# These key sizes exceed the default build's limits and require the larger applet variant.

load res/common.sh
load res/SmartPGP.common.sh

setup_file() {
    _setup_file
}

teardown_file() {
    _teardown_file
}

setup() {
    pgp_setup large
}

teardown() {
    # Remove generated keys and GPG state so tests are fully isolated.
    rm -rf /app/tmp
    rm -rf ~/.gnupg
    _teardown
}


@test "GPG generate RSA 3072 key and sign" {
    generate_sign RSA 3072
    [ "$?" == 0 ]
}

@test "GPG generate RSA 4096 key and sign" {
    generate_sign RSA 4096
    [ "$?" == 0 ]
}

@test "GPG import RSA 3072 key and sign" {
    algo_switch rsa3072
    write_rsa_keygen 3072
    import_sign
    [ "$?" == 0 ]
}

@test "GPG import RSA 4096 key and sign" {
    algo_switch rsa4096
    write_rsa_keygen 4096
    import_sign
    [ "$?" == 0 ]
}
