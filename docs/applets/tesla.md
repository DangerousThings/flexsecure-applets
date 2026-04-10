# Tesla Vehicle Access using Tesla Keycard

The Tesla Keycard applet allows a VivoKey Apex implant or wearable to act as a Tesla Key Card (TKC), enabling it to lock, unlock, and start a compatible Tesla vehicle. It implements the Tesla Key Card protocol using ECDH over NIST P-256 (secp256r1), the same cryptographic scheme used by official Tesla key cards.

> **Note:** This applet is not officially supported or endorsed by Tesla. Tesla could theoretically block third-party key cards via a software update; keys already paired with a vehicle may or may not continue to work in such a scenario.

## Applet Information

- Repository: <https://github.com/VivoKey/apex-tesla> (proprietary)
- Binary name: Not published
- AID: `74:65:73:6C:61:4C:6F:67:69:63:30:30:32:01`, Package: `74:65:73:6C:61:4C:6F:67:69:63`
- Fidesmo App ID: `e819c674`
- License: Proprietary

The package AID is ASCII-encoded: `teslaLogic`. The instance AID is `teslaLogic002` + `0x01`. The Fidesmo-deployed instance AID uses an `F` prefix (`F465...`) to conform to ISO 7816-5 for proprietary AIDs; the vehicle accepts both forms.

## Installation

The applet is only available via Fidesmo for VivoKey Apex devices. On installation, a unique ECDH P-256 key pair is generated on the chip. This key pair is permanent and specific to the device — it cannot be exported.

> **Important:** Uninstalling the applet destroys the key pair. If reinstalled, a new key pair is generated and the device must be re-registered with the vehicle.

## Using the Applet

### Pairing with a Vehicle

Pair the device with your Tesla using the same procedure as an official Tesla key card: open the Tesla app, go to **Locks → Add Key Card**, and tap the device to the centre console when prompted. The vehicle stores the device's public key and 7-byte NFC UID during pairing.

### Authentication

On each use, the vehicle performs a challenge-response authentication: it sends its own public key and a random challenge, the applet computes an ECDH shared secret and returns an AES-128 encrypted response. The vehicle decrypts the response and verifies it matches the challenge. No internet connection or server is involved.

## Sources and Further Reading

- <https://vivokey.com/tesla>

Improve this document: <https://github.com/DangerousThings/flexsecure-applets/tree/master/docs>
