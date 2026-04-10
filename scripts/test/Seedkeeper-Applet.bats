#!/usr/bin/env bats

load res/common.sh

SEEDKEEPER_PIN="12345678"
SEEDKEEPER_MNEMONIC="inmate slender predict future awful process fall normal view coast describe true prize filter grid throw wolf pool box tuna tonight blade retreat calm"

setup_file() {
    _setup_file
}

teardown_file() {
    _teardown_file
}

setup() {
    cd /tmp/builds/Seedkeeper-Applet
    java -cp /app/tools/jcardsim/target/jcardsim-3.0.5-SNAPSHOT.jar:./target \
        com.licel.jcardsim.remote.VSmartCard \
        /app/src/scripts/test/res/SeedkeeperApplet.jcardsim.cfg > /dev/null &
    JCSIM_PID="$!"
    sleep 2
    # Install with 4 kB vault size parameter (0x1000 = 4096 bytes)
    opensc-tool -r 'Virtual PCD 00 00' -s "80 b8 00 00 10 0B 53 65 65 64 4B 65 65 70 65 72 00 00 02 10 00 FF"
    printf '%s\n%s\n' "$SEEDKEEPER_PIN" "$SEEDKEEPER_PIN" | setsid satochip-cli common-initial-setup
}

teardown() {
    _teardown
}

seedkeeper_import_test_mnemonic() {
    printf '%s\n' "$SEEDKEEPER_MNEMONIC" \
        | PYSATOCHIP_PIN="$SEEDKEEPER_PIN" satochip-cli seedkeeper-import-secret \
            --type BIP39_mnemonic \
            --label "test mnemonic" \
            --export-rights Plaintext_export_allowed
}


@test "SeedKeeper card status shows zero secrets" {
    PYSATOCHIP_PIN="$SEEDKEEPER_PIN" satochip-cli seedkeeper-get-card-status | grep -q "nb_secrets: 0"
}

@test "SeedKeeper import BIP39 mnemonic" {
    seedkeeper_import_test_mnemonic | grep -q "Imported - SID:"
    # BIP39 mnemonic import creates two secrets: the mnemonic and the derived masterseed
    PYSATOCHIP_PIN="$SEEDKEEPER_PIN" satochip-cli seedkeeper-get-card-status | grep -q "nb_secrets: 2"
}

@test "SeedKeeper list secrets shows imported mnemonic" {
    seedkeeper_import_test_mnemonic
    PYSATOCHIP_PIN="$SEEDKEEPER_PIN" satochip-cli seedkeeper-list-secret-headers | grep -q "test mnemonic"
}

@test "SeedKeeper export secret recovers mnemonic plaintext" {
    seedkeeper_import_test_mnemonic
    # SID 0 is the BIP39 mnemonic; SID 1 is the derived masterseed stored alongside it
    PYSATOCHIP_PIN="$SEEDKEEPER_PIN" satochip-cli seedkeeper-export-secret --sid 0 | grep -q "$SEEDKEEPER_MNEMONIC"
}

@test "SeedKeeper generate on-card masterseed" {
    PYSATOCHIP_PIN="$SEEDKEEPER_PIN" satochip-cli seedkeeper-generate-masterseed \
        --label "generated seed" \
        --export-rights Plaintext_export_allowed | grep -q "Imported - SID:"
    PYSATOCHIP_PIN="$SEEDKEEPER_PIN" satochip-cli seedkeeper-list-secret-headers | grep -q "generated seed"
}

@test "SeedKeeper print logs" {
    seedkeeper_import_test_mnemonic
    # Logs must contain at least one entry with an operation type and result
    PYSATOCHIP_PIN="$SEEDKEEPER_PIN" satochip-cli seedkeeper-print-logs | grep -qE "Operation|Import|Export"
    PYSATOCHIP_PIN="$SEEDKEEPER_PIN" satochip-cli seedkeeper-print-logs | grep -qiE "ok|success|0x00"
}
