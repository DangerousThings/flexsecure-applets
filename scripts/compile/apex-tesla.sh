#!/bin/bash

mkdir -p /app/src/bin /app/src/applets/apex-tesla/target
cd /app/src/applets/apex-tesla
ant
cp /app/src/applets/apex-tesla/target/*.cap /app/src/bin/
