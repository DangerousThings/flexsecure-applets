#!/bin/bash

cd "${0%/*}"

echo "Cleaning Flex-OTP"
./docker-run.sh "cd /app/applets/Flex-OTP && rm -rf target"

echo "Cleaning openjavacard-ndef"
./docker-run.sh "cd /app/applets/openjavacard-ndef && rm -rf build"

echo "Cleaning SmartPGP"
./docker-run.sh "cd /app/applets/SmartPGP && rm -f *.cap"

echo "Cleaning vk-ykhmac"
./docker-run.sh "cd /app/applets/vk-ykhmac && rm -rf target/*.cap target/com/vivokey/ykhmac"

echo "Cleaning binaries"
rm -rf ../bin/*.cap
