# Encryption and Signatures using PGP

PGP (Pretty Good Privacy), and its popular implementation GnuPG (GNU Privacy Guard) are used to securely sign, encrypt and decrypt data.

Explaining the theory of public-key cryptography is out of scope, please refer to the sources below for more info.

## Applet Information

- Repository: <https://github.com/ANSSI-FR/SmartPGP> (`javacard-3.0.4-without-secure-messaging` branch)
- Binary name: `SmartPGPApplet-default.cap` and `SmartPGPApplet-large.cap`
- Download: <https://github.com/DangerousThings/flexsecure-applets/releases>
- AID: `D2:76:00:01:24:01:03:04:00:0A:00:00:00:00:00:00` (configurable, see below), Package: `D2:76:00:01:24:01`
- Fidesmo App ID: `30c2ea30`
- License: GPL v2
- Supported algorithms: RSA 2048, 3072, 4096; ECDSA/ECDH over NIST P-256, P-384, P-521 and Brainpool-r1 256, 384, 512. Secure messaging is not supported.
- Storage requirements:
   - Persistent: `24776` bytes (`28148` with one RSA 2048 key)
   - Transient reset: `2118` bytes
   - Transient deselect: `16` bytes

## Compiling the Applet Yourself

Setup your environment as described in *JavaCard Development Setup*. The build scripts in `scripts/compile/` automate the steps below.

A custom `build.xml` is required:

```bash
cp scripts/compile/res/SmartPGP.build.xml applets/SmartPGP/build.xml
JC_HOME=<sdks>/jc304_kit ant
```

This produces both `target/SmartPGPApplet-default.cap` and `target/SmartPGPApplet-large.cap`.

## Using Large Keys

If you want to use RSA keys larger than 2048 bits, you have to change the constant `INTERNAL_BUFFER_MAX_LENGTH` (default configuration: `0x500`) in `src/fr/anssi/smartpgp/Constants.java`:

- for RSA 2048 bits at least `0x3b0`
- for RSA 3072 bits at least `0x570`
- for RSA 4096 bits at least `0x730` (large configuration)

Otherwise, gpg might fail with a message like `gpg: KEYTOCARD failed: Hardware problem`.

You might also want to use my Docker image and build environment, which contains all necessary packages for compilation and testing: <https://github.com/DangerousThings/flexsecure-applets> . This environment automatically builds both the default and large configuration.

For more options, see the SmartPGP README file.

## Installing the Applet

To install the applet to your card, you have to first construct a valid AID (refer to section 4.2.1 of the OpenPGP card specification, linked below). Every AID starts with `D2 76 00 01 24 01`, which is the unique identifier of the FSFE, joined with the application identifier `01`. Next comes the OpenPGP version, which is `03 04` (3.4) for this applet. The next two bytes are a manufacturer id, which should be registered with the FSF Europe e.V. , however you can just put whatever you like - Vivokey uses `00 0A`. The next four bytes specify the card serial number (e.g. `00 00 00 01`), and the last two bytes are reserved for future use and are always zero.

The complete AID should look like this: `D2 76 00 01 24 01 03 04 C0 FE 00 00 00 01 00 00`.

Use GlobalPlatformPro (GPP) from <https://github.com/martinpaljak/GlobalPlatformPro/releases> to install the applet:

```bash
gp -install SmartPGPApplet.cap -create D276000124010304C0FE000000010000
```

Listing the applets using `gp --list` should print something like this:

```text
APP: D276000124010304C0FE000000010000 (SELECTABLE)
     Parent:   A000000151000000
     From:     D27600012401

PKG: D27600012401 (LOADED)
     Parent:   A000000151000000
     Version:  1.0
     Applet:   D276000124010304AFAF000000000000  
```

For more options, see the SmartPGP README file.

## Using the Applet

For usage, refer to the manuals for GnuPGP, GPG4Win, OpenKeychain, Thunderbird, or whatever you use PGP with. The card should behave like a YubiKey or OpenPGP card, so you can use instructions for these tokens as well.

### Importing Keys

Due to an implementation detail of the SmartPGP applet (<https://github.com/ANSSI-FR/SmartPGP/issues/15>), the card has to be configured for a specific algorithm before an existing key can be imported. This can be done using the `smartpgp-cli` tool in `SmartPGP/bin/`. For example, to configure the card for NIST P-521, run `./smartpgp-cli switch-p521`. You might have to install various Python 3 modules like `pyscard` and `pyasn1` using your system or Python package manager.

Generating keys on the card itself can be done for any algorithm without having to pre-configure the algorithm.

## Sources and Further Reading

- <https://en.wikipedia.org/wiki/Public-key_cryptography>
- <https://en.wikipedia.org/wiki/Pretty_Good_Privacy>
- <https://www.thunderbird.net/>
- <https://gnupg.org/>
- <https://en.wikipedia.org/wiki/OpenPGP_card>
- <https://gnupg.org/ftp/specs/OpenPGP-smart-card-application-3.4.pdf>
- <https://www.gpg4win.org/>

Improve this document: <https://github.com/DangerousThings/flexsecure-applets/tree/master/docs>
