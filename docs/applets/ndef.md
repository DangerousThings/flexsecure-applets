# Storing Data using NDEF

NDEF (NFC Data Exchange Format) is a standard data format used to store structured data on NFC tags, such as URLs, text, vCards, and custom records.

## Applet History

Two different NDEF applets are available. Both use the same instance AID (`D2:76:00:00:85:01:01`) but have different CAP package AIDs, so only one can be installed at a time.

### openjavacard-ndef (Deprecated)

[openjavacard-ndef](https://github.com/OpenJavaCard/openjavacard-ndef) is an open-source, standards-compliant NFC Forum Tag Type 4 applet. It is deprecated in favour of apex-ndef for Apex/Fidesmo deployments, but remains available for manual installation on flexSecure devices where the CMAC signature feature is not needed.

- CAP Package AID: `D2:76:00:00:85`
- Instance AID: `D2:76:00:00:85:01:01`

### apex-ndef / NFC Share (Active)

[apex-ndef](https://github.com/VivoKey/apex-ndef) is VivoKey's proprietary NDEF applet, branded as *NFC Share*. It extends the NFC Forum T4T 2.0 specification with an AES128-CMAC signature feature: a special template string in the NDEF data is dynamically replaced with a per-read signature derived from the chip UID and a rolling counter, allowing server-side verification of tap authenticity. When deployed via Fidesmo, the signature key is generated and bound to the user's Fidesmo account.

- CAP Package AID: `D2:76:00:00:85:01`
- Instance AID: `D2:76:00:00:85:01:01`

Note: the instance AID is the same as openjavacard-ndef; only the CAP package differs. The Fidesmo destroy recipe removes both package AIDs to handle devices that may have either version installed.

## Applet Information

### apex-ndef / NFC Share (Active)

- Repository: <https://github.com/VivoKey/apex-ndef>
- Binary name: Not published (deployed via Fidesmo only)
- AID: `D2:76:00:00:85:01:01`, Package: `D2:76:00:00:85:01`
- Standard: NFC Forum Tag Type 4 Operation Specification v2.0
- License: Proprietary

Supported features:

- NFC Forum T4T 2.0 conformant
- Up to 32 kB NDEF file size
- Configurable 7-byte UID (set once at install time)
- AES128-CMAC signature generation over UID and rolling counter (ISO9797-M2 padding)
- Dynamic signature overlay via template string in NDEF data
- One-way read-only lock (instruction `0xE1`, APDU `00 E1 00 00`)

### openjavacard-ndef (Deprecated)

- Repository: <https://github.com/OpenJavaCard/openjavacard-ndef>
- Binary names: `openjavacard-ndef-full.cap` (read-write), `openjavacard-ndef-tiny.cap` (read-only, static data)
- Download: <https://github.com/DangerousThings/flexsecure-applets/releases>
- AID: `D2:76:00:00:85:01:01`, Package: `D2:76:00:00:85`
- Standard: NFC Forum Tag Type 4
- License: GPL v3
- Storage requirements:
   - Persistent: `4372` bytes
   - Transient reset: `16` bytes
   - Transient deselect: `0` bytes

## Compiling the Applet Yourself

Setup your environment as described in *JavaCard Development Setup*. The build scripts in `scripts/compile/` automate the steps below.

**apex-ndef** uses Ant with the `jc305u3_kit` SDK:

```bash
JC_HOME=<sdks>/jc305u3_kit ant
```

**openjavacard-ndef** uses Ant with the older `jc222_kit` SDK, and requires a custom `build.xml` provided in `scripts/compile/res/openjavacard-ndef.build.xml`:

```bash
cp scripts/compile/res/openjavacard-ndef.build.xml applets/openjavacard-ndef/build.xml
ant -DJAVACARD_HOME=<sdks>/jc222_kit build
```

This produces four variants; the relevant outputs are `*full.cap` (read-write) and `*tiny.cap` (read-only static).

## Installing the Applet

### apex-ndef

apex-ndef is deployed via Fidesmo for Apex devices as the *NFC Share* app. The Fidesmo service handles key generation and binding. Available storage sizes are 1 kB, 2 kB, 4 kB, 8 kB, 16 kB, 32 kB, and custom.

For manual installation, use GlobalPlatformPro (GPP) from <https://github.com/martinpaljak/GlobalPlatformPro/releases>. The install parameter is 41 bytes, concatenated:

| Offset | Length | Content |
| ------ | ------ | ------- |
| 0      | 2      | NDEF file size in bytes (big-endian), e.g. `0x8000` for 32 kB |
| 2      | 7      | Unique chip ID |
| 9      | 16     | AES128 CMAC key |
| 25     | 16     | CMAC signature salt |

```bash
gp --install apex-ndef.cap --create D2760000850101 --params <41-byte-parameter>
```

To lock the applet into read-only mode after writing data:

```bash
gp --apdu 00E10000
```

### openjavacard-ndef

Use GlobalPlatformPro (GPP) to install openjavacard-ndef. The `-create` AID must be specified explicitly.

To install the `full` (read-write) variant with 2 kB storage:

```bash
gp --install openjavacard-ndef-full.cap --create D2760000850101 --params 8102000082020800
```

The TLV configuration format supports several options — see the openjavacard-ndef install documentation at <https://github.com/OpenJavaCard/openjavacard-ndef/blob/master/doc/install.md>.

To install the `tiny` (read-only) variant with a static URL `https://chrz.de`:

```bash
gp --install openjavacard-ndef-tiny.cap --create D2760000850101 --params d90108015531046368727a2e6465
```

You can generate the parameter data for the `tiny` variant using Python 3 and the `ndeflib` pip module:

```python
import ndef
record = ndef.Record('urn:nfc:wkt:U', '1', b'\x04chrz.de')
print((b''.join((ndef.message_encoder([record])))).hex())
```

Listing the applets using `gp --list` should print something like this:

```text
APP: D2760000850101 (SELECTABLE)
     Parent:  A000000151000000
     From:    D276000177100211030001

PKG: D276000177100211030001 (LOADED)
     Parent:  A000000151000000
     Version: 0.0
     Applet:  D27600017710021103000101
```

## Using the Applet

NDEF is widely supported by most smartphones.

To write data to a read-write tag, use NFC Tools Pro on Android, or the `pcsc_ndef.py` tool from <https://github.com/Giraut/pcsc-ndef> on PC:

```bash
echo PAYLOAD | python3 pcsc_ndef.py -r "READER" -t 4 write

python3 pcsc_ndef.py -r "READER" -t 4 read
```

Specify your reader using the `-r` flag.

### apex-ndef CMAC Signature Verification

#### How the Signature Works

To use the signature feature, embed the template string `{AES128_CMAC_SIGNATURE_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}` anywhere in your NDEF URL. On each read, the applet dynamically replaces it with a `UID-COUNTER-SIGNATURE` value in hex. For example, if you program the URL:

```
https://vivokey.com/demo/sigtest/?s={AES128_CMAC_SIGNATURE_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}
```

A phone tap will open a URL like:

```
https://vivokey.com/demo/sigtest/?s=FF0A01128731FBB6-000005-E92AB4B81AAA1FEAB2C4D2AF4665AD19
```

The signature format is `UID-COUNTER-SIGNATURE`, all in hexadecimal. The algorithm is `AES128-CMAC(SALT | UID | COUNTER)` using ISO9797-M2 padding. The counter is a 3-byte value stored in the chip and incremented once per NFC session; it cannot be rolled back.

#### Verifying with the VivoKey API

When deployed via Fidesmo, VivoKey holds the key server-side and provides the [Verify API](https://vivokey.com/api/) for signature validation. The base URL is `https://auth.vivokey.com`.

**Required headers:**

| Header          | Value |
| --------------- | ----- |
| `X-API-VIVOKEY` | Your API key |
| `Content-Type`  | `application/json` |

**POST `/validate`** — verifies the signature and returns a signed JWT on success:

```json
{ "signature": "FF0A01128731FBB6-000005-E92AB4B81AAA1FEAB2C4D2AF4665AD19" }
```

You can also pass the full URL containing the signature value and the API will extract it:

```json
{ "signature": "https://vivokey.com/demo/sigtest/?s=FF0A01128731FBB6-000005-E92AB4B81AAA1FEAB2C4D2AF4665AD19" }
```

Optional request fields:

| Key   | Description |
| ----- | ----------- |
| `aud` | Audience claim embedded into the resulting JWT |
| `cld` | Arbitrary client data string (up to 2048 characters), embedded into the JWT |

**Response fields:**

| Key      | Description |
| -------- | ----------- |
| `result` | `success`, `expired`, or `invalid` |
| `token`  | Signed authenticity JWT — only present when `result` is `success` |

The JWT `atp` claim will be `"cmac"` to indicate CMAC-based verification. You can inspect the JWT at <https://jwt.io>.

**POST `/validate.json`** — same as `/validate` but returns unsigned JSON instead of a JWT, useful when you do not need signed tokens:

```json
{
  "dev_id": "aaa1c9d1-078d-45c3-adfe-4274ccee9043",
  "atp": "cmac",
  "result": "success",
  "type": 3,
  "product": 8,
  ...
}
```

#### Expired Signatures

If the same signature is submitted a second time (e.g. a user reloads the page), the API returns `expired`. This means the signature is cryptographically valid but is no longer considered unique — no JWT is issued.

```json
{ "result": "expired" }
```

#### Security Caveats

The signature counter is incremented by the chip and cannot be rolled back, but the system is counter-based rather than time-based. This means an attacker could perform a series of rapid reads to **stockpile** valid signatures for later use. The practical risk depends on your application design:

- The Verify API tracks the highest counter value it has validated for each chip.
- Any signature with a counter value lower than the last validated one returns `expired`.
- Once a legitimate user taps and their signature is validated, all previously stockpiled lower-counter signatures are immediately invalidated.

For example: an attacker stockpiles signatures with counters 89103–89118. A legitimate user taps and their counter 89119 is validated. All attacker signatures are now expired and useless.

## Sources and Further Reading

- <https://vivokey.com/api/>
- <https://learn.adafruit.com/adafruit-pn532-rfid-nfc/ndef>
- <https://developer.nordicsemi.com/nRF_Connect_SDK/doc/1.0.0/nrf/include/nfc/ndef/nfc.html>
- <http://sweet.ua.pt/andre.zuquete/Aulas/IRFID/11-12/docs/NFC%20Data%20Exchange%20Format%20(NDEF).pdf>
- <https://www.netes.com.tr/netes/dosyalar/dosya/B6159F60458582512B16EF1263ADE707.pdf>
- <https://github.com/OpenJavaCard/openjavacard-ndef/tree/master/doc>
- <https://github.com/Giraut/pcsc-ndef>
- <https://github.com/nfcpy/ndeflib>
- <https://ndeflib.readthedocs.io/en/latest>
- <https://play.google.com/store/apps/details?id=com.wakdev.nfctools.pro>

Improve this document: <https://github.com/DangerousThings/flexsecure-applets/tree/master/docs>
