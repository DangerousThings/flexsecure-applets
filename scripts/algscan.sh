#!/usr/bin/env bash

grep -Er '\b(Cipher|Signature|MessageDigest|RandomData|KeyBuilder|KeyAgreement|Checksum|KeyPair|AEADCipher|OwnerPINBuilder|InitializedMessageDigest)\.[A-Z]' --include='*.java' applets/ \
  | grep -vE '/(test|sdks)/' \
  | grep -v '\.MODE_' \
  | sed -E 's|^applets/([^/]+)/[^:]*:(.*)|\1: \2|'