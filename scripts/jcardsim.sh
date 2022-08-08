#!/bin/bash

cd /app/src/jcardsim
JC_CLASSIC_HOME=/app/sdks/jc305u3_kit/ mvn initialize
JC_CLASSIC_HOME=/app/sdks/jc305u3_kit/ mvn clean install