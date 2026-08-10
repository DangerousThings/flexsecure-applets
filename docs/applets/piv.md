# PIV Smart Card (Personal Identity Verification)

PIV is a US government standard (FIPS 201 / SP 800-73) for smart card-based authentication, signing, and encryption. It is widely supported on Linux, macOS, and Windows through OpenSC and PKCS#11, and is compatible with tools and services that accept YubiKey PIV tokens.

## Applet Information

- Repository: <https://git.dngr.us/VivoKey/vkpiv.git> (proprietary)
- Binary name: Not published
- AID: `A0:00:00:03:08:00:00:10:00:01:00`, Package: `A0:00:00:03:08:00:00:10:00`
- Fidesmo App ID: `e9b30b9e`
- License: Proprietary
- Supported algorithms: ECCP256, ECCP384, RSA 1024, RSA 2048

## Slots

PIV defines several key slots, each intended for a different purpose:

| Slot | Name | Purpose |
| ---- | ---- | ------- |
| `9A` | PIV Authentication | Authenticating to systems and services |
| `9B` | Card Management | Administrative operations (management key, not a key pair) |
| `9C` | Digital Signature | Signing documents and code |
| `9D` | Key Management | Encryption and key exchange |
| `9E` | Card Authentication | Physical access control |

## Default Credentials

Fresh installs ship with these defaults — change them before use in any real context.

| Credential | Default |
| ---------- | ------- |
| PIN | `123456` |
| PUK | `12345678` |
| Management key (3DES) | `010203040506070801020304050607080102030405060708` |

## Installation

The applet is deployed via Fidesmo as the *VivoKey PIV* app on VivoKey Apex devices. No manual installation is required.

## Using the Applet

Install `yubico-piv-tool` and `opensc` using your package manager. The card behaves like a YubiKey PIV token, so any tool or guide written for YubiKey PIV applies.

Throughout these examples, set your reader name once:

```bash
READER='ACS ACR1252 Dual Reader [ACR1252 Dual Reader PICC] 00 00'  # adjust to match yours
```

List available readers:

```bash
opensc-tool -l
```

### Check Card Status

```bash
yubico-piv-tool -r "$READER" -a status
```

Expected output includes the firmware version, serial number, auto-generated CHUID and CCC, and PIN retry count.

### Change Default Credentials

Change the PIN (current → new):

```bash
yubico-piv-tool -r "$READER" -a change-pin -P 123456 -N <new-pin>
```

Change the PUK:

```bash
yubico-piv-tool -r "$READER" -a change-puk -P 12345678 -N <new-puk>
```

Change the management key:

```bash
yubico-piv-tool -r "$READER" --key="010203040506070801020304050607080102030405060708" \
    -a set-mgm-key --new-key=<new-management-key>
```

### Generate a Key Pair On-Card

On-card key generation keeps the private key inside the card and never exports it.

```bash
yubico-piv-tool -r "$READER" --key="<management-key>" \
    -a generate -s 9a -A ECCP256 \
    -o public.pem
```

Supported algorithms: `ECCP256`, `ECCP384`, `RSA1024`, `RSA2048`.

### Create a Self-Signed Certificate

After generating a key, create a self-signed certificate using on-card signing:

```bash
yubico-piv-tool -r "$READER" \
    -a verify-pin -P <pin> \
    -a selfsign-certificate -s 9a -S '/CN=my-card/' \
    -i public.pem -o cert.pem
```

Then import the certificate back to the slot:

```bash
yubico-piv-tool -r "$READER" --key="<management-key>" \
    -a import-certificate -s 9a -i cert.pem
```

### Import an Existing Key and Certificate

If your key pair was generated externally (e.g. by a CA), import both:

```bash
# Generate a key with openssl (or use an existing one)
openssl ecparam -name prime256v1 -genkey -noout -out key.pem
openssl req -new -x509 -key key.pem -out cert.pem -days 365 -subj '/CN=my-card/'

yubico-piv-tool -r "$READER" --key="<management-key>" \
    -a import-key -s 9a -i key.pem

yubico-piv-tool -r "$READER" --key="<management-key>" \
    -a import-certificate -s 9a -i cert.pem
```

### Read a Certificate from the Card

```bash
yubico-piv-tool -r "$READER" -a read-certificate -s 9a
```

Pipe to OpenSSL to inspect it:

```bash
yubico-piv-tool -r "$READER" -a read-certificate -s 9a | openssl x509 -noout -text
```

### Sign Data and Verify

Sign arbitrary data using the private key in slot 9a via PKCS#11:

```bash
pkcs11-tool --slot-index <index> --login --pin <pin> \
    --sign --mechanism ECDSA-SHA256 \
    --input-file data.txt \
    --output-file data.sig \
    --signature-format openssl
```

Verify with OpenSSL using the public key extracted from the certificate:

```bash
yubico-piv-tool -r "$READER" -a read-certificate -s 9a \
    | openssl x509 -noout -pubkey > pubkey.pem

openssl dgst -sha256 -verify pubkey.pem -signature data.sig data.txt
```

### List Certificates and Keys via OpenSC

OpenSC recognises the card as a PIV token and exposes it via PKCS#15:

```bash
pkcs15-tool -r "$READER" --list-certificates
pkcs15-tool -r "$READER" --list-keys
```

### System Authentication (SSH, sudo, etc.)

The card can be used for SSH authentication via PKCS#11. Export the public key:

```bash
ssh-keygen -D /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so
```

Add the output to `~/.ssh/authorized_keys` on the server, then connect using:

```bash
ssh -I /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so user@host
```

The PKCS#11 module path may differ by distribution — check `opensc-tool --info` or your package's installed files.

## Sources and Further Reading

- <https://en.wikipedia.org/wiki/FIPS_201>
- <https://csrc.nist.gov/pubs/sp/800/73/pt1/5/final>
- <https://developers.yubico.com/PIV/>
- <https://developers.yubico.com/yubico-piv-tool/>
- <https://github.com/OpenSC/OpenSC/wiki/US-PIV>

Improve this document: <https://github.com/DangerousThings/flexsecure-applets/tree/master/docs>
