#!/bin/bash

echo "Compiling Flex-OTP"
cd /app/src/applets/Flex-OTP && ant dist && cp /app/src/applets/Flex-OTP/target/*.cap /app/src/bin/

echo "Compiling openjavacard-ndef"
cd /app/src/applets/openjavacard-ndef && ant -DJAVACARD_HOME=/app/sdks/jc222_kit build && cp /app/src/applets/openjavacard-ndef/build/javacard/*.cap /app/src/bin/

echo "Compiling SmartPGP"
cd /app/src/applets/SmartPGP && JC_HOME=/app/sdks/jc304_kit ant convert && cp /app/src/applets/SmartPGP/*.cap /app/src/bin/

echo "Compiling vk-ykhmac"
cd /app/src/applets/vk-ykhmac && ant dist && cp /app/src/applets/vk-ykhmac/target/*.cap /app/src/bin/
