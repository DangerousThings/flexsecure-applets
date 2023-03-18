#!/usr/bin/env bash

echo "Making credential CTAP1"
CID=`fido2-cred -M -u -i test_fido2_make.txt pcsc://slot2 es256 | sed -n 5p`
echo "Credential ID: $CID"

echo ""
echo "Asserting credential CTAP1"
fido2-assert -G -u -p pcsc://slot2 <<EOF
$(cat test_fido2_make.txt | sed -n 1,2p)
$CID
EOF

echo ""
echo "Asserting credential CTAP2"
fido2-assert -G -p pcsc://slot2 <<EOF
$(cat test_fido2_make.txt | sed -n 1,2p)
$CID
EOF
