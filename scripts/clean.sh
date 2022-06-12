#!/bin/bash

echo "Cleaning Flex-OTP"
cd /app/src/applets/Flex-OTP && rm -rf target

echo "Cleaning openjavacard-ndef"
cd /app/src/applets/openjavacard-ndef && rm -rf build

echo "Cleaning SmartPGP"
cd /app/src/applets/SmartPGP && rm -f *.cap

echo "Cleaning vk-ykhmac"
cd /app/src/applets/vk-ykhmac && rm -rf target/*.cap target/com/vivokey/ykhmac

echo "Cleaning binaries"
rm -rf /app/src/bin/*.cap
