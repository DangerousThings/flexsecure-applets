#!/bin/bash

mkdir -p /app/src/bin
cd /app/src/applets/apex-totp
ant dist
cp /app/src/applets/apex-totp/target/*.cap /app/src/bin/
