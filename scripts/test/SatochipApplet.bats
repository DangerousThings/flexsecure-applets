#!/usr/bin/env bats

load res/common.sh

SATOCHIP_PIN="12345678"
# Fixed mnemonic gives deterministic xpub/address output for assertion matching.
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
    sleep 5
    AID='5361746F4368697000'
    # GlobalPlatform INSTALL: SatochipApplet ("SatoChip\x00").
    opensc-tool -r 'Virtual PCD 00 00' -s "$(_install_apdu "$AID" '00 00 FF')"
    sleep 3
    # common-initial-setup prompts for PIN twice via getpass (requires a TTY);
    # setsid allocates a new session so getpass falls back to stdin.
    printf '%s\n%s\n' "$SATOCHIP_PIN" "$SATOCHIP_PIN" | setsid satochip-cli common-initial-setup
}

teardown() {
    _teardown
}

# Import the fixed test mnemonic. Most tests depend on this to have a key loaded.
satochip_import_test_mnemonic() {
    printf '%s\n' "$SATOCHIP_MNEMONIC" | PYSATOCHIP_PIN="$SATOCHIP_PIN" satochip-cli satochip-import-unencrypted-mnemonic
}

# Derive and return the xpub at m/44'/0'/0'/0 for the given PIN.
# Used both to verify derivation works and to confirm PIN acceptance/rejection.
satochip_get_xpub() {
    PYSATOCHIP_PIN="$1" satochip-cli satochip-bip32-get-xpub --path "m/44'/0'/0'"
}


@test "version" {
    _test_version "$AID"
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
    # common-change-pin also uses getpass (old PIN + new PIN twice) → setsid required.
    printf '%s\n%s\n%s\n' "$SATOCHIP_PIN" "$new_pin" "$new_pin" | setsid satochip-cli common-change-pin | grep -q "Success: Pin Changed"
    satochip_get_xpub "$new_pin" | grep -q "xpub"
    # The CLI exits 0 even when the card rejects a wrong PIN, so check output not exit code.
    ! satochip_get_xpub "$SATOCHIP_PIN" | grep -q "xpub"
}
