# Cryptocurrency Hardware Wallet using SatoChip and SeedKeeper

The Satochip family consists of three related JavaCard applets sharing the same ecosystem of client software and the same Fidesmo deployment tooling:

- **SatoChip** — a BIP32/BIP39 hierarchical deterministic cryptocurrency hardware wallet
- **SeedKeeper** — a secure vault for storing seed phrases, passwords, and arbitrary secrets
- **Satodime** — a bearer cold-storage card (deprecated for implants; see below)

## Applet Information

### SatoChip (Active)

SatoChip (**S**ecure **A**nonymous **T**rustless and **O**pen **Chip**) implements a full BIP32/BIP39 HD wallet on a JavaCard. Private keys are generated and stored on the chip and never exported; all signing operations happen on-chip.

- Repository: <https://github.com/Toporin/SatochipApplet>
- Binary name: `SatoChip.cap`
- Download: <https://github.com/Toporin/SatochipApplet/releases>
- AID: `53:61:74:6F:43:68:69:70:00`, Package: `53:61:74:6F:43:68:69:70`
- Fidesmo App ID: `c7bfbf0b`
- License: AGPL v3

The AID is ASCII-encoded: `SatoChip` + `00` instance suffix. Protocol version in this build: `0.12`. Applet version: `0.6`.

Supported features:

- BIP32 hierarchical deterministic key derivation (secp256k1)
- BIP39 seed import
- Encrypted seed import from a SeedKeeper applet
- Up to 16 imported non-BIP32 private keys (vanity keys, etc.)
- PIN protection (4–16 characters); optional unblock PIN
- HMAC-SHA512 key derivation (software implementation)
- ECDSA signing over secp256k1 (`ALG_ECDSA_SHA_256`)
- Optional HMAC-SHA1 2FA for transaction signing and seed operations
- Personalisation PKI: import/export of a device certificate and challenge-response authentication
- Card label (user-assigned name stored on chip)
- Key derivation result caching in secure memory

### SeedKeeper (Active)

SeedKeeper is a secure secret vault for storing seed phrases, passwords, and other sensitive data. Secrets are stored encrypted on-chip using AES-128-ECB with a key generated randomly at applet installation. Each secret has a plaintext metadata header (type, label, export policy, use counter) that is only accessible after PIN entry.

- Repository: <https://github.com/Toporin/Seedkeeper-Applet>
- Binary name: `SeedKeeper.cap`
- Download: <https://github.com/Toporin/Seedkeeper-Applet/releases>
- AID: `53:65:65:64:4B:65:65:70:65:72:00`, Package: `53:65:65:64:4B:65:65:70:65:72`
- Fidesmo App ID: `3f660b6e`
- License: AGPL v3
- Storage: 18641 bytes persistent; vault size configurable at install time (up to 32 kB)

The AID is ASCII-encoded: `SeedKeeper` + `00` instance suffix. Protocol version in this build: `0.2`. Applet version: `0.1`.

Supported secret types:

| Type              | Description |
| ----------------- | ----------- |
| Master seed       | Raw BIP32 root secret; BIP39 subtype also stores entropy and passphrase |
| Electrum mnemonic | Electrum-format seed phrase with optional passphrase and wallet descriptor |
| Password          | Password string with optional login and URL fields |
| Master password   | Derivable master password |
| Symmetric key     | AES or other symmetric key material |
| 2FA secret        | TOTP/HOTP second factor secret |
| Public key        | Raw secp256k1 public key (compressed or uncompressed) |

Each secret can be assigned an export policy: forbidden, plaintext allowed, or encrypted-only (exported wrapped with the destination card's authentikey). The card tracks plaintext and encrypted export counts per secret.

### Satodime (Unused)

- Repository: <https://github.com/Toporin/Satodime-Applet>
- Binary name: `Satodime.cap`
- Download: <https://github.com/Toporin/Satodime-Applet/releases>
- AID: `53:61:74:6F:44:69:6D:65:00`, Package: `53:61:74:6F:44:69:6D:65`
- Fidesmo App ID: N/A
- License: AGPL v3

The AID is ASCII-encoded: `SatoDime` + `00` instance suffix.

Satodime is a bearer card concept: keypairs are generated on-chip and stay sealed (private key hidden) until explicitly unsealed by the bearer, at which point the private key is revealed. It is intended to physically pass cryptocurrency between people like a banknote, relying on the sealed state as a trust guarantee.

This concept is **not suitable for implants**. Satodime's trust model depends on the bearer being unable to unseal the card undetected — which is not a meaningful constraint when the card is permanently implanted in the owner's body. The transfer-of-ownership workflow (wired interface for new-owner pairing, NFC for sensitive operations) also has no practical application in an implant context. See <https://satochip.io/satodime-ownership-explained/> for a full explanation of the ownership model.

## Compiling the Applets Yourself

Setup your environment as described in *JavaCard Development Setup*. The build scripts in `scripts/compile/` automate the steps below. All three applets use `jc304_kit` with Ant and a custom `build.xml`.

**SatoChip:**

```bash
cp scripts/compile/res/SatochipApplet.build.xml applets/SatochipApplet/build.xml
JC_HOME=<sdks>/jc304_kit ant
```

Produces `target/SatoChip.cap`.

**SeedKeeper:**

```bash
cp scripts/compile/res/Seedkeeper-Applet.build.xml applets/Seedkeeper-Applet/build.xml
JC_HOME=<sdks>/jc304_kit ant
```

Produces `target/SeedKeeper.cap`.

**Satodime:**

```bash
cp scripts/compile/res/Satodime-Applet.build.xml applets/Satodime-Applet/build.xml
JC_HOME=<sdks>/jc304_kit ant
```

Produces `target/Satodime.cap`.

## Installing the Applets

Use GlobalPlatformPro (GPP) from <https://github.com/martinpaljak/GlobalPlatformPro/releases>.

**SatoChip** — no install parameter required:

```bash
gp --install SatoChip.cap
```

**SeedKeeper** — the vault storage size is set at install time via the `--params` flag. The parameter is the size in bytes as a 2-byte big-endian value:

```bash
gp --install SeedKeeper.cap --params 1000  # 4 kB
gp --install SeedKeeper.cap --params 4000  # 16 kB
gp --install SeedKeeper.cap --params 8000  # 32 kB (maximum)
```

**Satodime** — no install parameter required:

```bash
gp --install Satodime.cap
```

After installation, each applet must be initialised by a client application on first use. The client prompts for a PIN code to secure the card.

## Using the Applets

### Client Software

[Satochip-Utils](https://github.com/Toporin/Satochip-Utils) is the official management application for all three Satochip family cards. It handles card setup, PIN management, seed import, secret management, card-to-card backup, label configuration, and authenticity verification. It runs on Windows, macOS, and Linux.

For wallet operations with SatoChip, several established software wallets are supported:

- **Sparrow Wallet** (Bitcoin)
- **Electrum** (Bitcoin): natively supports SatoChip via the hardware wallet plugin
- **Electron Cash** (Bitcoin Cash): natively supports SatoChip
- **Electrum ABC** (eCash/XEC): natively supports SatoChip
- **Uniblow** (multi-coin)

For building custom integrations, a Python library is available:

- [pysatochip](https://github.com/Toporin/pysatochip) — Python library (LGPL v3) with CLI tool (`satochip-cli`), available via `pip install pysatochip`

### SatoChip PIN and Security

The chip enforces a PIN of 4–16 characters. After a configurable number of failed attempts, the PIN is blocked and can only be unblocked with a separate unblock PIN. All private key operations (derivation, signing, seed reset) require a valid PIN.

An optional HMAC-SHA1 2FA key can be configured. When 2FA is active, transaction signing and destructive operations (seed reset, 2FA key reset) additionally require a valid HMAC-SHA1 response, compatible with the Yubikey challenge-response protocol.

### SeedKeeper Secret Management

On first use, the client prompts for a PIN. Secrets can then be generated on-card (using on-chip randomness with optional user-supplied entropy) or imported from the client. Each secret is assigned a label and an export policy at import time.

Card-to-card backup is supported: secrets with an appropriate export policy can be exported from one SeedKeeper (encrypted with the destination card's authentikey) and imported to another, so the secret never appears in plaintext outside a secure chip. Individual secrets can also be erased from the card.

SeedKeeper v0.2 additionally supports: deriving a BIP32 extended key directly from a stored masterseed, deriving passwords from a stored master password, querying memory usage (`getSeedKeeperStatus`), and an NFC enable/disable policy.

**Factory reset** in v0.2 is triggered by blocking both the PIN and the PUK (entering wrong values repeatedly). This differs from v0.1, which used an explicit reset command.

### Interaction Between SatoChip and SeedKeeper

SatoChip (protocol version 0.12+) can import an encrypted BIP32 masterseed directly from a SeedKeeper using the `exportSecretToSatochip()` operation. The masterseed is transferred encrypted between the two chips and never appears in plaintext outside a secure chip. This enables a workflow where SeedKeeper acts as a secure backup for one or more SatoChip wallets.

## Sources and Further Reading

- <https://satochip.io>
- <https://satochip.io/product/satochip/>
- <https://satochip.io/software/>
- <https://github.com/Toporin/SatochipApplet>
- <https://github.com/Toporin/Seedkeeper-Applet>
- <https://github.com/Toporin/Satodime-Applet>
- <https://github.com/Toporin/Satochip-Utils>
- <https://github.com/Toporin/pysatochip>
- <https://satochip.io/satodime-ownership-explained/>

Improve this document: <https://github.com/DangerousThings/flexsecure-applets/tree/master/docs>
