#!/bin/bash

cd /app/src/applets/vk-ykhmac
ant dist
cp /app/src/applets/vk-ykhmac/target/*.cap /app/src/bin/
