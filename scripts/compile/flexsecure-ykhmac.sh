#!/bin/bash

mkdir -p /app/src/bin
cd /app/src/applets/flexsecure-ykhmac
ant dist
cp /app/src/applets/flexsecure-ykhmac/target/*.cap /app/src/bin/
cp /usr/bin/yktool.jar /app/src/bin/
