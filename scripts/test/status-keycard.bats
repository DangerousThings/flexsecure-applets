#!/usr/bin/env bats

load res/common.sh

KEYCARD_PIN="123456"
KEYCARD_PUK="123456789012"
KEYCARD_PAIRING="KeycardDefaultPairing"

setup_file() { 
    _setup_file
}

teardown_file() {
    _teardown_file
}

setup() {
    cd /tmp/builds/status-keycard
    java -cp /app/tools/jcardsim/target/jcardsim-3.0.5-SNAPSHOT.jar:/tmp/builds/status-keycard/build/classes/java/main \
        com.licel.jcardsim.remote.VSmartCard \
        /app/src/scripts/test/res/status-keycard.jcardsim.cfg > /dev/null &
    JCSIM_PID="$!"
    sleep 2
    opensc-tool -r 'Virtual PCD 00 00' -s "80 b8 00 00 0C 09 A0 00 00 08 04 00 01 01 01 00 00 FF"
    opensc-tool -r 'Virtual PCD 00 00' -s "80 b8 00 00 0C 09 A0 00 00 08 04 00 01 03 01 00 00 FF"
}

teardown() { _teardown; }

# Session 1: initialize only. keycard-init regenerates the SC keypair internally;
# all subsequent operations must run in a fresh shell so keycard-select picks up
# the new public key before OPEN SECURE CHANNEL.
keycard_init() {
    printf '%s\n' \
        "keycard-select" \
        "keycard-set-secrets $KEYCARD_PIN $KEYCARD_PUK $KEYCARD_PAIRING" \
        "keycard-init" \
        | keycard shell 2>&1
}

# Pair without opening a secure channel. Accepts optional extra commands.
keycard_pair() {
    printf '%s\n' \
        "keycard-select" \
        "keycard-set-secrets $KEYCARD_PIN $KEYCARD_PUK $KEYCARD_PAIRING" \
        "keycard-pair" \
        "$@" \
        | keycard shell 2>&1
}

# Session 2+: fresh SELECT returns the post-init SC public key, enabling correct
# ECDH for OPEN SECURE CHANNEL. Accepts any number of commands to run after auth.
keycard_session() {
    printf '%s\n' \
        "keycard-select" \
        "keycard-set-secrets $KEYCARD_PIN $KEYCARD_PUK $KEYCARD_PAIRING" \
        "keycard-pair" \
        "keycard-open-secure-channel" \
        "keycard-verify-pin $KEYCARD_PIN" \
        "$@" \
        | keycard shell 2>&1
}


@test "Keycard info shows not initialized before setup" {
    keycard info 2>&1 | grep -q "Initialized: false"
}

@test "Keycard info shows cash applet with secp256k1 public key" {
    # Uncompressed secp256k1 public key: 04 prefix + 64 bytes = 130 hex chars
    keycard info 2>&1 | grep -qiE "PublicKey: 0x04[0-9a-f]{128}"
}

@test "Keycard info shows cash applet Ethereum address" {
    keycard info 2>&1 | grep -qiE "Address: 0x[0-9a-f]{40}"
}

@test "Keycard init shows card as initialized" {
    keycard_init
    keycard info 2>&1 | grep -q "Initialized: true"
}

@test "Keycard init enables key management capability" {
    keycard_init
    keycard info 2>&1 | grep -q "Key management:true"
}

@test "Keycard init provides 10 pairing slots" {
    keycard_init
    keycard info 2>&1 | grep -q "AvailableSlots: 0x0a"
}

@test "Keycard pairing produces valid credentials" {
    keycard_init
    keycard_pair | grep -qiE "PAIRING INDEX: [0-9]"
}

@test "Keycard pairing reduces available slot count" {
    keycard_init
    keycard_pair
    keycard info 2>&1 | grep -q "AvailableSlots: 0x09"
}

@test "Keycard secure channel opens after init" {
    keycard_init
    keycard_session "keycard-get-status" | grep -qiE "PIN retry|Pin retry"
}

@test "Keycard generate key" {
    keycard_init
    keycard_session "keycard-generate-key"
    keycard info 2>&1 | grep -q "Key Initialized: true"
}

@test "Keycard export secp256k1 public key" {
    keycard_init
    # Output: "EXPORTED PUBLIC KEY\n04<128 hex chars>" (no 0x prefix)
    keycard_session \
        "keycard-generate-key" \
        "keycard-export-key-public m/44'/60'/0'/0/0" \
        | grep -qiE "^04[0-9a-f]{128}$"
}

@test "Keycard sign hash with derived key" {
    keycard_init
    # keycard-sign-with-path takes <hash> <path> (hash first); output includes ETH SIGNATURE
    keycard_session \
        "keycard-generate-key" \
        "keycard-sign-with-path 0000000000000000000000000000000000000000000000000000000000000000 m/44'/60'/0'/0/0" \
        | grep -qiE "ETH SIGNATURE: 0x[0-9a-f]{130}"
}

@test "Keycard generate BIP39 mnemonic on-card" {
    keycard_init
    # CS=6: 192 bits → 18 words; CLI outputs raw MNEMONIC INDEXES not resolved words
    keycard_session "keycard-generate-mnemonic 6" | grep -qE "MNEMONIC INDEXES \[[0-9]"
}

@test "Keycard change PIN" {
    local new_pin="654321"
    keycard_init
    keycard_session "keycard-change-pin $new_pin"
    # Verify new PIN authenticates successfully in a fresh session
    keycard shell 2>&1 <<EOF | grep -qiE "PIN retry|Pin retry"
keycard-select
keycard-set-secrets $new_pin $KEYCARD_PUK $KEYCARD_PAIRING
keycard-pair
keycard-open-secure-channel
keycard-verify-pin $new_pin
keycard-get-status
EOF
}

@test "Cash applet signs Ethereum hash" {
    keycard shell 2>&1 <<EOF | grep -qiE "ETH SIGNATURE: 0x[0-9a-f]{130}"
cash-select
cash-sign 0000000000000000000000000000000000000000000000000000000000000000
EOF
}

@test "Cash applet recovered address matches reported address" {
    local info_addr sign_addr
    info_addr=$(keycard info 2>&1 | grep -i "Address:" | grep -oiE "0x[0-9a-f]{40}" | tr '[:upper:]' '[:lower:]')
    sign_addr=$(keycard shell 2>&1 <<EOF | grep -i "ADDRESS:" | grep -oiE "0x[0-9a-f]{40}" | tr '[:upper:]' '[:lower:]'
cash-select
cash-sign 0000000000000000000000000000000000000000000000000000000000000000
EOF
)
    [ -n "$info_addr" ]
    [ "$info_addr" = "$sign_addr" ]
}
