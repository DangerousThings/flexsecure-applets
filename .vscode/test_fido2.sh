#!/usr/bin/env bash

RP="relyingpartyid.yeet.boi.domain.long.example.de"
USRID="averylonwell@averyloesting.example.de"
ALG="rs256"
IFACE="pcsc://slot0"

echo ""
echo "Making credential CTAP2"
echo "What does the fox say" | openssl sha256 -binary | base64 > cred_param
echo $RP >> cred_param
echo $USRID >> cred_param
dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 >> cred_param
fido2-cred -M -i cred_param $IFACE $ALG | fido2-cred -V -o cred $ALG

echo ""
echo "Verifying credential CTAP2"
echo "Who is still hungy" | openssl sha256 -binary | base64 > assert_param
echo $RP >> assert_param
head -1 cred >> assert_param
tail -n +2 cred > pubkey
fido2-assert -G -i assert_param $IFACE $ALG | fido2-assert -V pubkey -d $ALG