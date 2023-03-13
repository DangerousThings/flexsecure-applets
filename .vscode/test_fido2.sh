#!/usr/bin/env bash

echo "Making credential"
CID=`fido2-cred -M -h -i test_fido2_make.txt /dev/hidraw5 es256 | sed -n 5p`
echo "Credential ID: $CID"

echo ""
echo "Asserting credential"
fido2-assert -G -h -p /dev/hidraw5 <<EOF
$(cat test_fido2_make.txt | sed -n 1,2p)
$CID
h0nEaICZp9nP48+tS5gr1Vbge6PvwxBBC3LldQjH39gUTsiN5cuoJlKMcqXY5h1k9+HbOb3cP554yx8qULTRLA==
EOF