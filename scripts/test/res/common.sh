#!/usr/bin/env bash

_setup_file() {
    mkdir -p /run/pcscd
    pcscd -f --disable-polkit &
    PCSCD_PID="$!"
    sleep 4
}

_teardown_file() {
    kill $PCSCD_PID
}

_teardown() {
    kill $JCSIM_PID
    sleep 4
}

_install_apdu() {
    # Build a GP INSTALL APDU with dynamically computed AID-length byte and Lc.
    # Usage: _install_apdu <AID-hex-no-spaces> <trailing-hex-including-Le>
    # Lc = AID_LEN + TRAIL_LEN  (= 1[AID-len byte] + AID_LEN + [TRAIL_LEN-1 data bytes])
    local AID="$1"
    local TRAIL="$2"
    local AID_LEN=$(( ${#AID} / 2 ))
    local AID_HEX
    AID_HEX=$(echo "$AID" | fold -w2 | paste -sd ' ')
    local TRAIL_LEN
    TRAIL_LEN=$(echo "$TRAIL" | grep -oE '[0-9A-Fa-f]{2}' | wc -l)
    local LC
    LC=$(printf '%02X' $(( AID_LEN + TRAIL_LEN )))
    echo "80 b8 00 00 $LC $(printf '%02X' $AID_LEN) $AID_HEX $TRAIL"
}

_test_version() {
    # Select the applet by AID (hex, no spaces) then send the injected version APDU (INS=F4 P1=99 P2=99).
    # Response layout (from version.py): [appMajor appMinor buildMajor buildMinor buildPatch]
    # Passes if SW 9000 is returned with exactly 5 bytes, and if $DRONE_TAG is set (e.g. "v0.20.0"),
    # bytes 2-4 must match the build version encoded by version.py.
    local AID="$1"
    local AID_LEN=$(( ${#AID} / 2 ))
    local AID_HEX
    AID_HEX=$(echo "$AID" | fold -w2 | paste -sd ' ')
    local OUT
    OUT=$(opensc-tool -r 'Virtual PCD 00 00' \
        -s "00 A4 04 00 $(printf '%02X' $AID_LEN) $AID_HEX" \
        -s "00 F4 99 99 05")
    # Check the last response is SW 9000.
    echo "$OUT" | grep 'Received' | tail -1 | grep -q 'SW1=0x90, SW2=0x00' || return 1
    # Extract the 5 response bytes after the last Received header.
    local LAST_RECV_LINE
    LAST_RECV_LINE=$(echo "$OUT" | grep -n 'Received' | tail -1 | cut -d: -f1)
    local BYTES
    read -ra BYTES <<< "$(echo "$OUT" | tail -n "+$((LAST_RECV_LINE + 1))" | grep -oE '\b[0-9A-Fa-f]{2}\b' | tr '\n' ' ')"
    [ "${#BYTES[@]}" -eq 5 ] || return 1
    # Verify bytes 2-4 match the build version from $DRONE_TAG (e.g. "v0.20.0"), as encoded by version.py.
    local VER_PARTS
    IFS='.' read -ra VER_PARTS <<< "${DRONE_TAG#v}"
    [ "$((16#${BYTES[2]}))" -eq "${VER_PARTS[0]}" ] || return 1
    [ "$((16#${BYTES[3]}))" -eq "${VER_PARTS[1]}" ] || return 1
    [ "$((16#${BYTES[4]}))" -eq "${VER_PARTS[2]}" ] || return 1
}