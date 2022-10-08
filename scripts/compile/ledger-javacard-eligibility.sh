#!/bin/bash

mkdir -p /app/src/bin /app/src/applets/ledger-javacard-eligibility/applet/target
cd /app/src/applets/ledger-javacard-eligibility/applet
for fname in src/com/ledger/eligibility/*.javap; do
    cpp -P $fname "${fname%.javap}.java"
done
cp /app/src/scripts/compile/res/ledger-javacard-eligibility.build.xml .
JC_HOME=/app/sdks/jc304_kit ant -buildfile ledger-javacard-eligibility.build.xml
cp /app/src/applets/ledger-javacard-eligibility/applet/target/*.cap /app/src/bin/
cd /app/src/applets/ledger-javacard-eligibility/reporting
mvn package
cp /app/src/applets/ledger-javacard-eligibility/reporting/target/*.jar /app/src/bin/
