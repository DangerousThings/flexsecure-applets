#!/bin/bash

cd /app/src/applets/Flex-OTP
ant dist
cp /app/src/applets/Flex-OTP/target/*.cap /app/src/bin/
