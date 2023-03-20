#!/usr/bin/env bash

echo "Making credential CTAP1"
CID=`fido2-cred -M -u -i test_fido2_make.txt pcsc://slot0 es256 | sed -n 5p`
echo "Credential ID: $CID"

echo ""
echo "Asserting credential CTAP1"
fido2-assert -G -u -p pcsc://slot0 <<EOF
$(cat test_fido2_make.txt | sed -n 1,2p)
$CID
EOF

echo ""
echo "Asserting credential CTAP2"
fido2-assert -G -p pcsc://slot0 <<EOF
$(cat test_fido2_make.txt | sed -n 1,2p)
$CID
EOF

echo ""
echo "Making credential CTAP2"
CID=`fido2-cred -M -i test_fido2_make.txt pcsc://slot0 es256 | sed -n 5p`
echo "Credential ID: $CID"

echo ""
echo "Asserting credential CTAP1"
fido2-assert -G -u -p pcsc://slot0 <<EOF
$(cat test_fido2_make.txt | sed -n 1,2p)
$CID
EOF

echo ""
echo "Asserting credential CTAP2"
fido2-assert -G -p pcsc://slot0 <<EOF
$(cat test_fido2_make.txt | sed -n 1,2p)
$CID
EOF

echo ""
echo "Asserting invalid CTAP1"
fido2-assert -G -u -p pcsc://slot0 <<EOF
$(cat test_fido2_make.txt | sed -n 1,2p)
H96FcEKdL85h2X2BZhzbuBL4KEahWc3HX1q4tGUubmvdlLCv4sEZGGCPtl0qTVQOEzxTDaQALgMe4bNdnhNjmKK4foXprSIS2GhwrvSPHT5cokp40deciKG+zi/OkT1by9t72CYbhF8R510/4Rb4dA==
EOF

echo ""
echo "Asserting invalid CTAP2"
fido2-assert -G -p pcsc://slot0 <<EOF
$(cat test_fido2_make.txt | sed -n 1,2p)
H96FcEKdL85h2X2BZhzbuBL4KEahWc3HX1q4tGUubmvdlLCv4sEZGGCPtl0qTVQOEzxTDaQALgMe4bNdnhNjmKK4foXprSIS2GhwrvSPHT5cokp40deciKG+zi/OkT1by9t72CYbhF8R510/4Rb4dA==
EOF