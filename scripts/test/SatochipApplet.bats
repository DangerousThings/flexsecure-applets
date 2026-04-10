#!/usr/bin/env bats

load res/common.sh

SATOCHIP_PIN="12345678"
SATOCHIP_MNEMONIC="ripple shaft cactus chaos science safe review bench rare fun royal ginger crowd feed have citizen pigeon office avoid agent stumble wolf jar quantum"

setup_file() {
    _setup_file
}

teardown_file() {
    _teardown_file
}

setup() {
    cd /tmp/builds/SatochipApplet
    java -cp /app/tools/jcardsim/target/jcardsim-3.0.5-SNAPSHOT.jar:./target \
        com.licel.jcardsim.remote.VSmartCard \
        /app/src/scripts/test/res/SatochipApplet.jcardsim.cfg > /dev/null &
    JCSIM_PID="$!"
    sleep 2
    opensc-tool -r 'Virtual PCD 00 00' -s "80 b8 00 00 0C 09 53 61 74 6F 43 68 69 70 00 00 00 FF"
    printf '%s\n%s\n' "$SATOCHIP_PIN" "$SATOCHIP_PIN" | setsid satochip-cli common-initial-setup
}

teardown() {
    _teardown
}

satochip_import_test_mnemonic() {
    printf '%s\n' "$SATOCHIP_MNEMONIC" | PYSATOCHIP_PIN="$SATOCHIP_PIN" satochip-cli satochip-import-unencrypted-mnemonic
}

satochip_get_xpub() {
    PYSATOCHIP_PIN="$1" satochip-cli satochip-bip32-get-xpub --path "m/44'/0'/0'/0"
}


@test "Satochip card status shows initialized" {
    PYSATOCHIP_PIN="$SATOCHIP_PIN" satochip-cli common-get-card-status | grep -q "'setup_done': True"
}

@test "Satochip import BIP39 mnemonic" {
    satochip_import_test_mnemonic | grep -q "Seed Successfully Imported"
}

@test "Satochip BIP32 xpub derivation" {
    satochip_import_test_mnemonic
    satochip_get_xpub "$SATOCHIP_PIN" | grep -q "xpub"
}

@test "Satochip sign message with BIP32 key" {
    satochip_import_test_mnemonic
    PYSATOCHIP_PIN="$SATOCHIP_PIN" satochip-cli satochip-sign-message --message "Hello, CI" | grep -q "Signature (Base64):"
}

@test "Satochip change PIN" {
    local new_pin="87654321"
    satochip_import_test_mnemonic
    printf '%s\n%s\n%s\n' "$SATOCHIP_PIN" "$new_pin" "$new_pin" | setsid satochip-cli common-change-pin | grep -q "Success: Pin Changed"
    satochip_get_xpub "$new_pin" | grep -q "xpub"
    # Old PIN must be rejected — output must not contain a valid xpub
    ! satochip_get_xpub "$SATOCHIP_PIN" | grep -q "xpub"
}
