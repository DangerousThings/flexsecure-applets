# Universal Two-Factor Authentication using FIDO

FIDO U2F is a standard for two-factor authentication. It is extended and superseded by FIDO2, but still widely used. 

FIDO2 CTAP2 is an extension and improvement over FIDO U2F, and remains backwards-compatible to U2F.

The FIDO2 applet is still in development, and not completely finished. You can test the beta code, but keep in mind that some features do not work yet, e.g. Windows Hello. In addition, only the FIDO U2F applet has been certified to be standards compliant as of now.

## Applet Information

### FIDO U2F

- Repository: https://github.com/darconeous/u2f-javacard
- Binary name: `U2FApplet.cap`
- Download: https://github.com/StarGate01/flexsecure-applets/releases
- AID: `A0:00:00:06:47:2F:00:01`, Package: `a0:00:00:06:17:00:4f:97:a2:e9:50:01`

### FIDO2 CTAP2

- Repository: https://github.com/VivoKey/vk-u2f (forked from u2f-javacard)
- Binary name: `CTAP2.cap`
- Download: https://github.com/StarGate01/flexsecure-applets/releases
- AID: `A0:00:00:06:47:2F:00:01`, Package: `A0:00:00:06:47:2F:00:01`

## Compiling the Applet Yourself

Setup your environment as described in *JavaCard Development Setup* .

Use git to clone the sources recursively, and change into the directory. To compile, run `JC_HOME=<sdks>/jc304_kit ant`, replacing `<sdks>` with the path to your JavaCard SDKs.

## Installing the Applet

You can not use the U2F applet at the same time as the FIDO2 one because they use the same AID.

Use GlobalPlatformPro (GPP) from https://github.com/martinpaljak/GlobalPlatformPro/releases to install the applet:

Using the default example FIDO attestation certificate:

```
gp -install U2FApplet.cap --create A0000006472F0001 --params 000140f3fccc0d00d8031954f90864d43c247f4bf5f0665c6b50cc17749a27d1cf7664
```

You have to pass a few parameters for the installer, e.g. the private key of the attestation certificate. See https://github.com/darconeous/u2f-javacard/blob/master/README.md and for more details.

Listing the applets using `gp --list` should print something like this:

```
APP: A0000006472F0001 (SELECTABLE)
     Parent:  A000000151000000
     From:    A000000617004F97A2E95001

PKG: A000000617004F97A2E95001 (LOADED)
     Parent:  A000000151000000
     Version: 1.1
     Applet:  A000000617004F97A2E94901
```

Next, you have to load the attestation certificate by sending a few APDUs:

```
gp -d -v \
  -a "00 A4 04 00 08 A0 00 00 06 47 2F 00 01" \
  -a "80 01 00 00 80 30 82 01 3c 30 81 e4 a0 03 02 01 02 02 0a 47 90 12 80 00 11 55 95 73 52 30 0a 06 08 2a 86 48 ce 3d 04 03 02 30 17 31 15 30 13 06 03 55 04 03 13 0c 47 6e 75 62 62 79 20 50 69 6c 6f 74 30 1e 17 0d 31 32 30 38 31 34 31 38 32 39 33 32 5a 17 0d 31 33 30 38 31 34 31 38 32 39 33 32 5a 30 31 31 2f 30 2d 06 03 55 04 03 13 26 50 69 6c 6f 74 47 6e 75 62 62 79 2d 30 2e 34 2e 31 2d 34 37 39 30" \
  -a "80 01 00 80 80 31 32 38 30 30 30 31 31 35 35 39 35 37 33 35 32 30 59 30 13 06 07 2a 86 48 ce 3d 02 01 06 08 2a 86 48 ce 3d 03 01 07 03 42 00 04 8d 61 7e 65 c9 50 8e 64 bc c5 67 3a c8 2a 67 99 da 3c 14 46 68 2c 25 8c 46 3f ff df 58 df d2 fa 3e 6c 37 8b 53 d7 95 c4 a4 df fb 41 99 ed d7 86 2f 23 ab af 02 03 b4 b8 91 1b a0 56 99 94 e1 01 30 0a 06 08 2a 86 48 ce 3d 04 03 02 03 47 00 30 44 02 20 60 cd" \
  -a "80 01 01 00 40 b6 06 1e 9c 22 26 2d 1a ac 1d 96 d8 c7 08 29 b2 36 65 31 dd a2 68 83 2c b8 36 bc d3 0d fa 02 20 63 1b 14 59 f0 9e 63 30 05 57 22 c8 d8 9b 7f 48 88 3b 90 89 b8 8d 60 d1 d9 79 59 02 b3 04 10 df"
```

In the future, Vivokey or I will provide a nice tool to generate and load attestation certificates.

## Using the Applet

Using the applet requires a modern browser with support for FIDO. NFC tokens don't work on Linux (yet, see https://twitter.com/FIDOAlliance/status/1278331283874156544).

You can use the *Yubikey WebAuthn test page* at https://demo.yubico.com/webauthn-technical/registration to test your token.

On Android, you can use the *FIDO / Webauthn Example* App at https://play.google.com/store/apps/details?id=de.cotech.hw.fido.example for testing. 

## Sources and Further Reading

- https://en.wikipedia.org/wiki/Universal_2nd_Factor
- https://www.yubico.com/authentication-standards/fido-u2f/
- https://fidoalliance.org/fido-technotes-the-truth-about-attestation/
- https://gist.github.com/darconeous/adb1b2c4b15d3d8fbc72a5097270cdaf
- https://fidoalliance.org/specs/fido-u2f-v1.2-ps-20170411/fido-u2f-raw-message-formats-v1.2-ps-20170411.html#examples
- https://demo.yubico.com/webauthn-technical/registration
- https://en.wikipedia.org/wiki/FIDO2_Project
- https://www.1kosmos.com/authentication/fido2-authentication/
- https://research.kudelskisecurity.com/2020/02/12/fido2-deep-dive-attestations-trust-model-and-security/
- https://fidoalliance.org/specs/fido-v2.0-rd-20180702/fido-client-to-authenticator-protocol-v2.0-rd-20180702.html
- https://play.google.com/store/apps/details?id=de.cotech.hw.fido.example

Improve this document: https://github.com/StarGate01/flexsecure-applets/tree/master/docs