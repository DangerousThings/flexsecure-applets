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
    sleep 2
    CUID='fff860203a257128'
    KEY='20f780716ba49ae163bd638486c71723'
    opensc-tool -r 'Virtual PCD 00 00' -s "80 b8 00 00 27  0C A000000846737061726B3201 00 18 $CUID $KEY FF"
}

teardown() {
    _teardown
}


@test "Authentication positive" {
    cd /tmp/builds/apex-spark/test
    ./authenticate.py -k $KEY
}

@test "Authentication negative" {
    cd /tmp/builds/apex-spark/test
    run ./authenticate.py -k "ec96ca0a9bb855fac4bde8c2781f3f3d"
    [ "$status" -eq 1 ]
}
