#!/usr/bin/env bash

FIDO_RP="test.fido2.example.com"
FIDO_USRID="averylongaswell64k@longrelyingpartyid.averylongstring.example.de"
FIDO_PIN="1234"

_fido_make_assert_param() {
    dd if=/dev/urandom bs=1 count=16 2>/dev/null | openssl sha256 -binary | base64 > assert_param
    echo "$FIDO_RP" >> assert_param
}

_fido_build_opts() {
    # Sets MKOPT and VALOPT from $1 (hmac|*) and $2 (u2f|*)
    MKOPT=""
    VALOPT=""
    if [ "$1" == "hmac" ]; then
        MKOPT="-h"
        VALOPT="-h"
    fi
    if [ "$2" == "u2f" ]; then
        MKOPT="$MKOPT -u"
    fi
}

fido_set_pin() {
    printf '%s\n%s\n' "$FIDO_PIN" "$FIDO_PIN" | setsid fido2-token -S "pcsc://slot0"
}

fido_make_resident_cred() {
    # $1: algorithm (es256)
    dd if=/dev/urandom bs=1 count=16 2>/dev/null | openssl sha256 -binary | base64 > cred_param
    echo "$FIDO_RP" >> cred_param
    echo "Test User" >> cred_param
    dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 >> cred_param
    fido2-cred -M -r -i cred_param "pcsc://slot0" "$1" | fido2-cred -V -o cred "$1"
}

fido_attempt_assert_resident_cred() {
    # Attempts a discoverable assertion; returns authenticator exit code.
    # Use with `run` to check for expected failure.
    # $1: algorithm (es256)
    _fido_make_assert_param
    fido2-assert -G -r -i assert_param "pcsc://slot0" "$1"
}

fido_assert_resident_cred() {
    # $1: algorithm (es256)
    tail -n +2 cred > pubkey
    fido_attempt_assert_resident_cred "$1" | fido2-assert -V pubkey "$1"
}

fido_token_list_rps() {
    setsid fido2-token -L -r "pcsc://slot0" <<< "$FIDO_PIN"
}

fido_delete_resident_cred() {
    local cred_id
    cred_id=$(head -1 cred)
    setsid fido2-token -D -i "$cred_id" "pcsc://slot0" <<< "$FIDO_PIN"
}

fido_make_cred() {
    # $1: algorithm, $2: hmac|nohmac, $3: u2f|fido2
    _fido_build_opts "$2" "$3"
    dd if=/dev/urandom bs=1 count=16 2>/dev/null | openssl sha256 -binary | base64 > cred_param
    echo "$FIDO_RP" >> cred_param
    echo "$FIDO_USRID" >> cred_param
    dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 >> cred_param
    fido2-cred -M $MKOPT -i cred_param "pcsc://slot0" "$1" | fido2-cred -V $VALOPT -o cred "$1"
}

fido_assert_cred() {
    # $1: algorithm, $2: hmac|nohmac, $3: u2f|fido2
    _fido_build_opts "$2" "$3"
    _fido_make_assert_param
    head -1 cred >> assert_param
    if [ "$2" == "hmac" ]; then
        dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 >> assert_param
    fi
    tail -n +2 cred > pubkey
    fido2-assert -G $MKOPT -i assert_param "pcsc://slot0" "$1" | fido2-assert -V $VALOPT pubkey -d "$1"
}
