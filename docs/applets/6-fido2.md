# Universal Two-Factor Authentication using FIDO2

**FIDO2 CTAP2** (Client to Authenticator Protocol) is an extension and improvement over FIDO U2F.

The FIDO2 applet is still in development, and not completely finished. For example, Windows Hello is not supported yet. Stay tuned. It is also not officially certified.

You can however already test the FIDO2 applet via the Vivokey Apex on Fidesmo.

The FIDO2 applet source code is not publicly available (anymore). Binaries are only distributed via Fidesmo (as of now. There might be an option for a more free option in the future). If you want an open-source authenticator, use the U2F one.

## Applet Information

### FIDO2 CTAP2

- Repository: Private
- Binary name: Not published on GitHub
- Download: N/A
- AID: `a0:00:00:06:47:2F:00:01:01`, Package: `a0:00:00:06:47:2F:00:01`
- Storage requirements:
  - Persistent: `TBA` bytes
  - Transient reset: `TBA` bytes
  - Transient deselect: `TBA` bytes

## Using the Applet

Using the applet in the web requires a modern browser with support for FIDO. NFC tokens don't work on Linux (yet, see https://twitter.com/FIDOAlliance/status/1278331283874156544).

You can use the *Yubikey WebAuthn test page* at https://demo.yubico.com/webauthn-technical/registration to test your token.

On Android, you can use the *FIDO / Webauthn Example* App at https://play.google.com/store/apps/details?id=de.cotech.hw.fido.example for testing (Use the U2F tab), or use any Browser which supports the Security Manager (for details, see *Android Problems and Solutions*) and use the Yubico page.

## Sources and Further Reading

- https://fidoalliance.org/fido-technotes-the-truth-about-attestation/
- https://demo.yubico.com/webauthn-technical/registration
- https://en.wikipedia.org/wiki/FIDO2_Project
- https://www.1kosmos.com/authentication/fido2-authentication/
- https://research.kudelskisecurity.com/2020/02/12/fido2-deep-dive-attestations-trust-model-and-security/
- https://fidoalliance.org/specs/fido-v2.0-rd-20180702/fido-client-to-authenticator-protocol-v2.0-rd-20180702.html
- https://play.google.com/store/apps/details?id=de.cotech.hw.fido.example

Improve this document: https://github.com/DangerousThings/flexsecure-applets/tree/master/docs