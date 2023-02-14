#!/bin/bash

mkdir -p /app/src/bin /app/src/applets/teslaIdent/target
cd /app/src/applets/teslaIdent
ant
cp /app/src/applets/teslaIdent/target/*.cap /app/src/bin/
