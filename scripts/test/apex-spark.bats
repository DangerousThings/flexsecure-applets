#!/usr/bin/env bats

load res/common.sh

setup_file() {
    _setup_file
}

teardown_file() {
    _teardown_file
}

setup() {
    cd /tmp/builds/apex-spark
    java -cp /app/tools/jcardsim/target/jcardsim-3.0.5-SNAPSHOT.jar:./target com.licel.jcardsim.remote.VSmartCard /app/src/scripts/test/res/apex-spark.jcardsim.cfg > /dev/null &
    JCSIM_PID="$!"
    sleep 5
    AID='A000000846737061726B3201'
    CUID='fff860203a257128'              # 8-byte card unique ID
    KEY='20f780716ba49ae163bd638486c71723'  # AES-128 key for mutual challenge-response authentication
    # GlobalPlatform INSTALL: apex-spark, install params include CUID and KEY.
    opensc-tool -r 'Virtual PCD 00 00' -s "$(_install_apdu "$AID" "00 18 $CUID $KEY FF")"
    sleep 3
}

teardown() {
    _teardown
}


@test "version" {
    _test_version "$AID"
}

@test "Authentication positive" {
    # authenticate.py performs an AES-based challenge-response; success exits 0.
    cd /tmp/builds/apex-spark/test
    ./authenticate.py -k $KEY
}

@test "Authentication negative" {
    # A mismatched key must be rejected; run captures exit code.
    cd /tmp/builds/apex-spark/test
    run ./authenticate.py -k "ec96ca0a9bb855fac4bde8c2781f3f3d"
    [ "$status" -eq 1 ]
}
