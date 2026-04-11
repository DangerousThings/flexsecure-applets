#!/usr/bin/env bats

load res/common.sh
load res/NDEF.common.sh

setup_file() {
    _setup_file
}

teardown_file() {
    _teardown_file
}

setup() {
    cd /tmp/builds/apex-ndef
    java -cp /app/tools/jcardsim/target/jcardsim-3.0.5-SNAPSHOT.jar:./target com.licel.jcardsim.remote.VSmartCard /app/src/scripts/test/res/apex-ndef.jcardsim.cfg > /dev/null &
    JCSIM_PID="$!"
    sleep 5
    AID='D2760000850101'
    CUID='fff860203a257128'              # 8-byte card unique ID, embedded in NDEF URLs
    KEY='4173f37fbec4f93f3c66bb9fbf7284bf'  # AES-128 key used to compute CMAC
    SALT='ead73d4e5aeb64b0ddb26b470bb85856'  # Salt mixed into the CMAC input alongside CUID and counter
    # GlobalPlatform INSTALL: apex-ndef (NDEF Type 4 Tag), install params include CUID, KEY, SALT.
    opensc-tool -r 'Virtual PCD 00 00' -s "$(_install_apdu "$AID" "00 2A 0800 $CUID $KEY $SALT FF")"
    sleep 3
}

teardown() {
    _teardown
}


# Write a random URL with an embedded CMAC + counter into the NDEF record.
cmac_setup() {
    cd /tmp/builds/apex-ndef/test
    ./cmac.py randomurl | python3 ./pcsc-ndef/pcsc_ndef.py -r "Virtual PCD 00 00" -t4 write
}

# Read the current NDEF URL and verify its CMAC using the given key.
# The card increments an internal counter on each read; the CMAC covers CUID, SALT, and counter.
cmac_verify() {
    ./cmac.py verifyurl -k $1 -i $CUID -a $SALT -u $(python3 ./pcsc-ndef/pcsc_ndef.py -r "Virtual PCD 00 00" -t4 read 2>/dev/null)
    res=$?
    return $res
}


@test "version" {
    _test_version "$AID"
}

@test "NDEF check size" {
    ndef_check_size
}

@test "NDEF read write" {
    ndef_read_write
}

@test "NDEF CMAC positive" {
    cmac_setup
    # Verify three times to confirm the counter increments and each resulting CMAC is valid.
    cmac_verify $KEY
    cmac_verify $KEY
    cmac_verify $KEY
}

@test "NDEF CMAC negative" {
    cmac_setup
    # A wrong key must produce an invalid CMAC; run captures the exit code.
    run cmac_verify '1eedb2ff62cfe26dd58c8368d5169bdb'
    [ "$status" -eq 1 ]
}
