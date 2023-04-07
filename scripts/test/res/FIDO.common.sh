#!/usr/bin/env bash

FIDO_RP="longrelyingpartyid.yeetcool.boi.domain.verylonglong64.example.de"
FIDO_USRID="averylongaswell64k@longrelyingpartyid.averylongstring.example.de"

fido_make_cred() {
    dd if=/dev/urandom bs=1 count=16 2>/dev/null | openssl sha256 -binary | base64 > cred_param
    echo $FIDO_RP >> cred_param
    echo $FIDO_USRID >> cred_param
    MKOPT=""
    VALOPT=""
    if [ "$2" == "hmac" ]; then
        MKOPT="-h"
        VALOPT="-h"
    fi
    if [ "$3" == "u2f" ]; then
        MKOPT="$MKOPT -u"
    fi
    dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 >> cred_param
    fido2-cred -M $MKOPT -i cred_param "pcsc://slot0" $1 | fido2-cred -V $VALOPT -o cred $1
}

fido_assert_cred() {
    dd if=/dev/urandom bs=1 count=16 2>/dev/null | openssl sha256 -binary | base64 > assert_param
    echo $FIDO_RP >> assert_param
    head -1 cred >> assert_param
    MKOPT=""
    VALOPT=""
    if [ "$2" == "hmac" ]; then
        MKOPT="-h"
        VALOPT="-h"
        dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 >> assert_param
    fi
    if [ "$3" == "u2f" ]; then
        MKOPT="$MKOPT -u"
    fi
    tail -n +2 cred > pubkey
    fido2-assert -G $MKOPT -i assert_param "pcsc://slot0" $1 | fido2-assert -V $VALOPT pubkey -d $1
}
