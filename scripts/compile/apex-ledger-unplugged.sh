#!/bin/bash

cd /app/src/applets/apex-ledger-unplugged/src-preprocessed
for fname in com/ledger/wallet/*.javap; do
    cpp -P $fname "../src/${fname%.javap}.java"
done
rm -f /app/src/applets/apex-ledger-unplugged/src/com/ledger/wallet/LWNFCForumApplet.java
cd /app/src/applets/apex-ledger-unplugged
cp /app/src/scripts/compile/res/apex-ledger-unplugged.build.xml .
JC_HOME=/app/sdks/jc304_kit ant -buildfile apex-ledger-unplugged.build.xml
cp /app/src/applets/apex-ledger-unplugged/target/*.cap /app/src/bin/
