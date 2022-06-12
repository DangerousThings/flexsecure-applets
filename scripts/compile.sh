#!/bin/bash

cd "${0%/*}"

echo "Compiling Flex-OTP"
./docker-run.sh "cd /app/applets/Flex-OTP && ant dist && cp /app/applets/Flex-OTP/target/*.cap /app/bin/"

echo "Compiling openjavacard-ndef"
./docker-run.sh "cd /app/applets/openjavacard-ndef && ant -DJAVACARD_HOME=/app/sdks/jc222_kit build && cp /app/applets/openjavacard-ndef/build/javacard/*.cap /app/bin/"

echo "Compiling SmartPGP"
./docker-run.sh "cd /app/applets/SmartPGP && JC_HOME=/app/sdks/jc304_kit ant convert && cp /app/applets/SmartPGP/*.cap /app/bin/"

echo "Compiling vk-ykhmac"
./docker-run.sh "cd /app/applets/vk-ykhmac && ant dist && cp /app/applets/vk-ykhmac/target/*.cap /app/bin/"
