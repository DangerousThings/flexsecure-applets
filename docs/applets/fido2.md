# FIDO U2F and FIDO2 Authentication

**FIDO** (Fast IDentity Online) defines two standards for hardware-based two-factor and passwordless authentication:

- **FIDO U2F** (Universal 2nd Factor / CTAP1) — an older standard for second-factor authentication only.
- **FIDO2 CTAP2** (Client to Authenticator Protocol) — the modern successor, adding passkeys (resident credentials) and passwordless login.

## Applet History

Three different applets have been used for FIDO authentication on flexSecure and Apex devices. All three share the same CAP package AID (`A0:00:00:06:47:2F:00:01`), so only one can be installed at a time.

### u2f-javacard (Deprecated)

[u2f-javacard](https://github.com/darconeous/u2f-javacard) is an open-source FIDO U2F (CTAP1) only authenticator. It is deprecated because FIDO2Applet fully covers CTAP1/U2F as well — there is no reason to install u2f-javacard if FIDO2Applet is installed. It uses instance AID `A0:00:00:06:47:2F:00:01:01`.

### apex-fido2 (Deprecated)

[apex-fido2](https://github.com/VivoKey/apex-fido2) was VivoKey's proprietary FIDO2 implementation. Its source code is not public. It has been replaced by FIDO2Applet, which is open-source and more fully featured. It uses instance AID `A0:00:00:06:47:2F:00:01:02`. The attestation loader mode for apex-fido2 was `-m fido2`.

### FIDO2Applet (Active)

[FIDO2Applet](https://github.com/BryanJacobs/FIDO2Applet) by Bryan Jacobs is the currently active open-source FIDO2 CTAP2.1 implementation. It is preloaded on all flexSecure devices sold after December 2, 2024, and is the applet deployed via Fidesmo as the *FIDO Security* app for Apex devices. It uses instance AID `A0:00:00:06:47:2F:00:01:02` (same as apex-fido2 — using `-create` at install time to match the Fidesmo deployment and differentiate from u2f-javacard).

## Applet Information

### FIDO2Applet

- Repository: <https://github.com/BryanJacobs/FIDO2Applet>
- Binary name: `FIDO2.cap`
- Download: <https://github.com/DangerousThings/flexsecure-applets/releases>
- AID: `A0:00:00:06:47:2F:00:01:02`, Package: `A0:00:00:06:47:2F:00:01`
- Storage requirements:
   - Persistent: `~41748` bytes
   - Transient reset: `~2745` bytes
   - Transient deselect: `0` bytes

- Standard: FIDO2 CTAP2.1 (with CTAP1/U2F backwards compatibility)
- Extensions: `hmac-secret`, `credProtect`, `credBlob`, `largeBlobKey`, `minPinLength`, `uvm`

### apex-fido2 (Deprecated)

- Repository: <https://github.com/VivoKey/apex-fido2> (source not public)
- Binary name: Not published
- AID: `A0:00:00:06:47:2F:00:01:02`, Package: `A0:00:00:06:47:2F:00:01`
- Storage requirements:
   - Persistent: `19336` bytes
   - Transient reset: `2273` bytes
   - Transient deselect: `32` bytes

- Standard: FIDO2 CTAP2.0 (with CTAP1/U2F backwards compatibility)
- Extensions: `hmac-secret`, `credProtect`

### u2f-javacard (Deprecated)

- Repository: <https://github.com/darconeous/u2f-javacard>
- Binary name: `U2FApplet.cap`
- Download: <https://github.com/DangerousThings/flexsecure-applets/releases>
- AID: `A0:00:00:06:47:2F:00:01:01`, Package: `A0:00:00:06:47:2F:00:01`
- Storage requirements:
   - Persistent: `8020` bytes
   - Transient reset: `865` bytes
   - Transient deselect: `0` bytes

- Standard: FIDO U2F (CTAP1 only, no CTAP2)
- Extensions: none

## Attestation Certificates

All three applets require an attestation certificate. This certificate is used to sign responses from the authenticator so that relying parties can verify the manufacturer and model of the token. You don't want to generate a unique certificate per token, because that would make each token individually trackable — a fleet certificate shared across many devices is the norm.

The certificate can be self-generated, or an official one signed by a certificate authority like VivoKey. When deploying via Fidesmo, VivoKey's CA-signed certificate is automatically loaded.

For manual installs, use the [fido-attestation-loader](https://github.com/DangerousThings/fido-attestation-loader) tool. The key difference between applets is the `-m` mode flag, which controls the install parameter format and certificate upload APDU sequence:

| Applet       | Mode flag   | Notes |
| ------------ | ----------- | ----- |
| FIDO2Applet  | `-m fido21` | Active; uses CBOR install parameter |
| apex-fido2   | `-m fido2`  | Deprecated; uses 51-byte install parameter |
| u2f-javacard | `-m u2f`    | Deprecated; uses 35-byte install parameter, no AAGUID |

## Compiling the Applet Yourself

Setup your environment as described in *JavaCard Development Setup*. The build scripts in `scripts/compile/` automate the steps below.

**FIDO2Applet** uses Gradle with the `jc304_kit` SDK. The PackageID and ApplicationID must be specified explicitly:

```bash
JC_HOME=<sdks>/jc304_kit ./gradlew -PPackageID=A0000006472F0001 -PApplicationID=A0000006472F000101 buildJavaCard classes
```

The compiled `.cap` file will be placed in `build/javacard/`.

**apex-fido2** uses Ant with the `jc305u3_kit` SDK (note: different SDK version from the others):

```bash
JC_HOME=<sdks>/jc305u3_kit ant
```

**u2f-javacard** uses Ant with the `jc304_kit` SDK, but requires a custom `build.xml` provided in `scripts/compile/res/u2f-javacard.build.xml` — copy it into the repository root before building:

```bash
cp scripts/compile/res/u2f-javacard.build.xml applets/u2f-javacard/build.xml
JC_HOME=<sdks>/jc304_kit ant -f applets/u2f-javacard/build.xml
```

The compiled `.cap` file will be placed in `target/`.

## Installing the Applet

All three applets follow the same general flow: generate a certificate chain, install the applet with an install parameter containing the attestation private key, then upload the public certificate to the applet.

### Setup fido-attestation-loader

Install Python 3 and Pip, then install the requirements:

```bash
pip install -r requirements.txt
```

Copy `settings.example.ini` to `settings.ini` and fill in your metadata: description, organization name, AAGUID, and OIDs. If you want to generate a FIDO MDS entry, copy `icon.example.png` to `icon.png` or supply your own icon.

Private keys are encrypted with AES-256-CBC. You can provide passphrases interactively, via the `-p` / `-cap` command-line flags, or by storing them in files named `attestation_key.pass` and `ca_key.pass` in the tool's directory.

### Generate a Certificate Chain

The certificate generation steps are the same for all applets. Specify the correct `-m` flag for your target applet.

Create a certificate authority:

```bash
./attestation.py ca create
```

Create and sign an attestation certificate:

```bash
# For FIDO2Applet:
./attestation.py cert create -m fido21

# For u2f-javacard:
./attestation.py cert create -m u2f
```

Verify the signature:

```bash
./attestation.py cert validate
```

### Install Parameters

The install parameter format differs between applets. Use `cert show` with the correct mode to generate it:

```bash
./attestation.py cert show -m fido21   # FIDO2Applet
./attestation.py cert show -m u2f      # u2f-javacard
```

**FIDO2Applet (`-m fido21`):** The parameter is a CBOR map containing the private attestation key and configuration. It is generated automatically by the tool and passed directly to GPP.

**u2f-javacard (`-m u2f`):** The parameter is 35 bytes:

| Offset | Length | Content |
| ------ | ------ | ------- |
| 0      | 1      | Always `00` |
| 1      | 2      | Attestation certificate length (big-endian) |
| 3      | 32     | Attestation private key (P-256) |

**apex-fido2 (`-m fido2`):** The parameter is 51 bytes:

| Offset | Length | Content |
| ------ | ------ | ------- |
| 0      | 1      | Flags: `0x01` disable user presence, `0x02` allow unauthenticated reset, `0x04` disable CTAP1, `0x08` disable CTAP2 |
| 1      | 2      | Attestation certificate length (big-endian) |
| 3      | 32     | Attestation private key (P-256) |
| 35     | 16     | AAGUID |

### Install via GlobalPlatformPro

Use GlobalPlatformPro (GPP) from <https://github.com/martinpaljak/GlobalPlatformPro/releases>.

For **FIDO2Applet**, specify `-create A0000006472F000102` to match the Fidesmo deployment AID and distinguish it from u2f-javacard:

```bash
gp --install FIDO2.cap --create A0000006472F000102 --params <install-parameter>
```

Listing applets using `gp --list` should print something like this:

```text
APP: A0000006472F000102 (SELECTABLE)
     Parent:  A000000151000000
     From:    A0000006472F0001

PKG: A0000006472F0001 (LOADED)
     Parent:  A000000151000000
     Version: 1.0
     Applet:  A0000006472F000101
```

For **u2f-javacard**, no `-create` is needed — the instance AID defaults to the module AID:

```bash
gp --install U2FApplet.cap --params <install-parameter>
```

Listing applets using `gp --list` should print something like this:

```text
APP: A0000006472F000101 (SELECTABLE)
     Parent:  A000000151000000
     From:    A000000617004F97A2E95001

PKG: A000000617004F97A2E95001 (LOADED)
     Parent:  A000000151000000
     Version: 1.1
     Applet:  A000000617004F97A2E94901
```

### Upload the Attestation Certificate

After installation, upload the public attestation certificate to the applet using the attestation loader, with the same `-m` flag used during installation:

```bash
./attestation.py cert upload -m fido21   # FIDO2Applet
./attestation.py cert upload -m u2f      # u2f-javacard
```

Use `-r <index>` to specify a PC/SC reader (use `./attestation.py -l` to list available readers). On Windows, run as Administrator — the OS blocks low-level access to FIDO applets by default.

The tool sends the DER-encoded certificate in 128-byte chunks using chained APDUs. For U2F, the header format is `80 01 HHLL KK` where `HHLL` is the 16-bit byte offset of the chunk and `KK` is the chunk length. See <https://gist.github.com/darconeous/adb1b2c4b15d3d8fbc72a5097270cdaf> for the raw APDU details.

### Deploying via Fidesmo (Apex)

On VivoKey Apex devices, FIDO2Applet is deployed via Fidesmo as the *FIDO Security* app. The attestation certificate signed by the VivoKey CA is automatically installed during the Fidesmo service flow — no manual certificate loading is required.

## Using the Applet

FIDO2 and U2F require a modern browser with WebAuthn/FIDO support. NFC tokens do not currently work in Linux desktop browsers; use [CTAP-Bridge](https://github.com/StarGate01/CTAP-bridge) to proxy the NFC token as a virtual USB token on Linux.

Test pages:

- Yubico WebAuthn demo: <https://demo.yubico.com/webauthn-technical/registration>
- WebAuthn Debugger: <https://webauthn.me/debugger>

On Android, use any browser that supports the Security Key API, or the [FIDO/WebAuthn Example App](https://play.google.com/store/apps/details?id=de.cotech.hw.fido.example) for testing (use the U2F tab for u2f-javacard).

### Attestation

The attestation certificate is embedded in the applet at install time. It identifies the manufacturer and model of the authenticator, allowing relying parties to verify the token's origin. The certificate is signed by a certificate authority — either your own CA (self-generated) or the VivoKey CA (when deployed via Fidesmo).

See <https://fidoalliance.org/fido-technotes-the-truth-about-attestation/> for background on how FIDO attestation works.

### User Presence and User Verification

User presence is always ensured because NFC requires physical proximity. Only one operation is permitted per tap, after which the token must be re-presented — this defends against automated relay attacks.

User verification (FIDO2 only) is provided via the Client PIN protocol (version 1) and must be explicitly requested by the relying party. U2F does not support user verification.

### Server and Resident Credentials

By default, FIDO2Applet creates server credentials: the key material is encrypted into the credential ID and stored with the relying party rather than on the card. If the relying party requests a resident credential (passkey), the key material is stored on the applet, consuming persistent storage until the applet runs out of space.

U2F (CTAP1) only supports server credentials.

## Sources and Further Reading

- <https://en.wikipedia.org/wiki/FIDO2_Project>
- <https://en.wikipedia.org/wiki/Universal_2nd_Factor>
- <https://www.yubico.com/authentication-standards/fido-u2f/>
- <https://fidoalliance.org/fido-technotes-the-truth-about-attestation/>
- <https://fidoalliance.org/specs/fido-v2.0-rd-20180702/fido-client-to-authenticator-protocol-v2.0-rd-20180702.html>
- <https://fidoalliance.org/specs/fido-u2f-v1.2-ps-20170411/fido-u2f-raw-message-formats-v1.2-ps-20170411.html#examples>
- <https://research.kudelskisecurity.com/2020/02/12/fido2-deep-dive-attestations-trust-model-and-security/>
- <https://www.1kosmos.com/authentication/fido2-authentication/>
- <https://demo.yubico.com/webauthn-technical/registration>
- <https://play.google.com/store/apps/details?id=de.cotech.hw.fido.example>
- <https://github.com/DangerousThings/fido-attestation-loader>
- <https://gist.github.com/darconeous/adb1b2c4b15d3d8fbc72a5097270cdaf>
- <https://developers.yubico.com/U2F/Attestation_and_Metadata/>
- <https://fidoalliance.org/specs/fido-u2f-v1.2-ps-20170411/fido-u2f-authenticator-transports-extension-v1.2-ps-20170411.html>

Improve this document: <https://github.com/DangerousThings/flexsecure-applets/tree/master/docs>
