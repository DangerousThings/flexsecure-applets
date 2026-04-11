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
    sleep 5
    AID='A00000080400010101'
    opensc-tool -r 'Virtual PCD 00 00' -s "$(_install_apdu "$AID" '00 00 FF')"
    sleep 3
    opensc-tool -r 'Virtual PCD 00 00' -s "$(_install_apdu 'A00000080400010301' '00 00 FF')"
    sleep 3
}

teardown() {
    _teardown
}

# Session 1: initialize only. INITIALIZE APDU calls initSecureChannel() internally,
# which regenerates the SC keypair (A→B). All subsequent operations must run in a
# fresh shell so SELECT returns keypair B's public key before OPEN SECURE CHANNEL.
# Mixing init and pair in the same session causes an ECDH mismatch → SW 6982.
keycard_init() {
    printf '%s\n' \
        "keycard-select" \
        "keycard-set-secrets $KEYCARD_PIN $KEYCARD_PUK $KEYCARD_PAIRING" \
        "keycard-init" \
        | keycard shell 2>&1
}

# Pair without opening a secure channel. Accepts optional extra commands after pair.
# The pairing secret set by keycard-set-secrets is session-local and must be re-set
# in every shell invocation before keycard-pair.
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


@test "version" {
    _test_version "$AID"
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
    # Key management capability is off until INITIALIZE sets it.
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
    # keycard-get-status requires an open secure channel; PIN retry count confirms it worked.
    keycard_session "keycard-get-status" | grep -qiE "PIN retry|Pin retry"
}

@test "Keycard generate key" {
    keycard_init
    keycard_session "keycard-generate-key"
    keycard info 2>&1 | grep -q "Key Initialized: true"
}

@test "Keycard export secp256k1 public key" {
    keycard_init
    # Output line: "04<128 hex chars>" (no 0x prefix, unlike most other keycard-cli output).
    keycard_session \
        "keycard-generate-key" \
        "keycard-export-key-public m/44'/60'/0'/0/0" \
        | grep -qiE "^04[0-9a-f]{128}$"
}

@test "Keycard sign hash with derived key" {
    keycard_init
    # keycard-sign-with-path argument order: <hash> <path> (hash comes first).
    # Output includes R, S, V components and a combined ETH SIGNATURE line.
    keycard_session \
        "keycard-generate-key" \
        "keycard-sign-with-path 0000000000000000000000000000000000000000000000000000000000000000 m/44'/60'/0'/0/0" \
        | grep -qiE "ETH SIGNATURE: 0x[0-9a-f]{130}"
}

@test "Keycard generate BIP39 mnemonic on-card" {
    keycard_init
    # CS (checksum size) = 6 → 192 bits of entropy → 18 mnemonic words.
    # The CLI returns raw MNEMONIC INDEXES (11-bit BIP39 word indices), not resolved words.
    keycard_session "keycard-generate-mnemonic 6" | grep -qE "MNEMONIC INDEXES \[[0-9]"
}

@test "Keycard change PIN" {
    local new_pin="654321"
    keycard_init
    keycard_session "keycard-change-pin $new_pin"
    # Verify new PIN works in a fresh session (uses new_pin, so keycard_session cannot be reused here).
    keycard shell 2>&1 <<EOF | grep -qiE "PIN retry|Pin retry"
keycard-select
keycard-set-secrets $new_pin $KEYCARD_PUK $KEYCARD_PAIRING
keycard-pair
keycard-open-secure-channel
keycard-verify-pin $new_pin
keycard-get-status
EOF
}

# --- Cash applet (no secure channel required) ---

@test "Cash applet signs Ethereum hash" {
    # CashApplet signs directly without pairing or secure channel.
    keycard shell 2>&1 <<EOF | grep -qiE "ETH SIGNATURE: 0x[0-9a-f]{130}"
cash-select
cash-sign 0000000000000000000000000000000000000000000000000000000000000000
EOF
}

@test "Cash applet recovered address matches reported address" {
    # keycard info reports the CashApplet address; cash-sign recovers it from the signature.
    # Both must agree, confirming the key and the signing path are consistent.
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
