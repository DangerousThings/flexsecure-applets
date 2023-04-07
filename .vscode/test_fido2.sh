#!/usr/bin/env bash

RP="relyingpartyid.yeet.boi.domain.long.example.de"
USRID="averylonwell@averyloesting.example.de"
ALG="es256"
#HMAC="-h"
#U2F="-u"
IFACE="pcsc://slot0"

echo ""
echo "Making credential"
echo "What does the fox say" | openssl sha256 -binary | base64 > cred_param
echo $RP >> cred_param
echo $USRID >> cred_param
dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 >> cred_param
fido2-cred -M $U2F $HMAC -i cred_param $IFACE $ALG | fido2-cred -V $HMAC -o cred $ALG

echo ""
echo "Verifying credential"
echo "Who is still hungy" | openssl sha256 -binary | base64 > assert_param
echo $RP >> assert_param
head -1 cred >> assert_param
if [ ! -z "$HMAC" ]; then
    dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 >> assert_param
fi
tail -n +2 cred > pubkey
fido2-assert -G $U2F $HMAC -i assert_param $IFACE $ALG | fido2-assert -V $HMAC pubkey -d $ALG