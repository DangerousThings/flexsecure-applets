#!/bin/bash

echo "Cleaning Flex-OTP"
cd /app/src/applets/Flex-OTP && rm -rf target

echo "Cleaning openjavacard-ndef"
cd /app/src/applets/openjavacard-ndef && rm -rf build

echo "Cleaning SmartPGP"
cd /app/src/applets/SmartPGP && rm -rf target

echo "Cleaning vk-ykhmac"
cd /app/src/applets/vk-ykhmac && rm -rf target/*.cap target/com/vivokey/ykhmac
cd /app/src/applets/vk-ykhmac/tools/yktool && make clean

echo "Cleaning binaries"
cd /app/src/bin && rm *.cap *.jar
