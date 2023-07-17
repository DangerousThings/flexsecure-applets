# Universal Two-Factor Authentication using FIDO2

**FIDO2 CTAP2** (Client to Authenticator Protocol) is an extension and improvement over FIDO U2F.

The FIDO2 applet is still in development, and not completely finished. For example, Windows Hello is not supported yet. Stay tuned. It is also not officially certified.

You can however already test the FIDO2 applet via the Vivokey Apex on Fidesmo.

Supported features (if installed via Fidesmo):
 - Normal, chained and extended APDU support
 - Server and resident credentials
 - Credential types:
   - ECDSA P-256 + SHA-256 (ES2569)
   - RSASSA-PKCS1-v1_5 2048 + SHA-256 (RS256)
   - RSASSA-PSS 2048 + SHA-256 (PS256)
 - HMAC secret extension
 - Basic direct attestation using a fleet certificate
   - Signed by the VivoKey certificate authority
 - User verification types:
   - Client PIN protocol version 1
 - User presence (assuming the chip is implanted)
 - Multiple accounts per relying party
 - FIDO MDS entry

The FIDO2 applet source code is not publicly available (anymore). Binaries are only distributed via Fidesmo (as of now. Options on how to bring it to the FlexSecure are in development). If you want an open-source authenticator, use the U2F one.

## Applet Information

### FIDO2 CTAP2

- Repository: Private
- Binary name: Not published on GitHub
- Download: N/A
- AID: `a0:00:00:06:47:2F:00:01:01`, Package: `a0:00:00:06:47:2F:00:01`
- Storage requirements:
  - Persistent: `19336` bytes
  - Transient reset: `2273` bytes
  - Transient deselect: `32` bytes

## Using the Applet

Using the applet in the web requires a modern browser with support for FIDO. NFC tokens don't work on Linux browsers (yet, see https://twitter.com/FIDOAlliance/status/1278331283874156544), however you can use my CATP-Bridge (https://github.com/StarGate01/CTAP-bridge) to proxy NFC tokens as virtual USB tokens in Linux.

You can use the *Yubikey WebAuthn test page* at https://demo.yubico.com/webauthn-technical/registration or the Webauthn Debugger (https://webauthn.me/debugger) to test your token.

On Android, you can use the *FIDO / Webauthn Example* App at https://play.google.com/store/apps/details?id=de.cotech.hw.fido.example for testing, or use any Browser which supports the Security Manager (for details, see *Android Problems and Solutions*) and use the Yubico page.

### Attestation

Similar to the U2F applet, the FIDO2 applet contains an embedded attestation certificate and key of the manufacturer. This certificate is used to sign responses of the authenticator, such that the relying party can verify the manufacturer and model of the authenticator.

### User Presence and User Verification

User presence is always ensured by default, because the mode of data transportation is via NFC, which requires physical proximity. However, only one operation may be performed per touch, after which the token must be re-presented. This is to defend against automated attacks.

User verification has to be requested by the relying party and is provided via the client PIN protocol.

### Server and Resident Credentials

By default, the authenticator creates server credentials, which are not stored on the authenticator, but instead encoded and encrypted into the credential ID and stored with the relying party. If requested by the relying party, the authenticator will instead create a resident credential, which stores the key material on the authenticator until it runs out of storage space.

## Sources and Further Reading

- https://fidoalliance.org/fido-technotes-the-truth-about-attestation/
- https://demo.yubico.com/webauthn-technical/registration
- https://en.wikipedia.org/wiki/FIDO2_Project
- https://www.1kosmos.com/authentication/fido2-authentication/
- https://research.kudelskisecurity.com/2020/02/12/fido2-deep-dive-attestations-trust-model-and-security/
- https://fidoalliance.org/specs/fido-v2.0-rd-20180702/fido-client-to-authenticator-protocol-v2.0-rd-20180702.html
- https://play.google.com/store/apps/details?id=de.cotech.hw.fido.example

Improve this document: https://github.com/DangerousThings/flexsecure-applets/tree/master/docs