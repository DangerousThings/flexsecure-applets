#!/usr/bin/env bash

cd "${0%/*}"

rm -f *.pem *.csr *.der

openssl ecparam -genkey -noout -name prime256v1 -out attestation_key.pem
openssl req -config attestation.config -new -sha256 -key attestation_key.pem -out attestation.csr
openssl req -x509 -config attestation.config -extensions req_ext -sha256 -key attestation_key.pem -in attestation.csr -out attestation.pem -days 3650
openssl ec -in attestation_key.pem -text -noout
openssl x509 -outform der -in attestation.pem -out attestation.der
xxd -c 128 -p attestation.der
wc -c < attestation.der