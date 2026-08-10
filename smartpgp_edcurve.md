# SmartPGP Ed25519 / X25519 Integration Notes

Design notes for adding Ed25519 (EdDSA signing) and X25519 (ECDH encryption) support to the
SmartPGP JavaCard applet using the NXP JCOP 4.5 / J3R452 hardware Curve25519 implementation.

---

## Components

| Repo | License | Role |
|------|---------|------|
| `ANSSI-FR/SmartPGP` | GPL v2 | OpenPGP card 3.4 applet — fork target |
| `suut/Curve25519-JavaCard` | MIT | Publicly available binary (`.cap` + `.jar`) |
| `suut/Curve25519-JavaCard-Source` | NDA / proprietary | NXP wrapper source, private |

---

## OpenPGP card 3.4 spec support

Ed25519 and X25519 are both defined in the OpenPGP card 3.x specification:

- **EdDSA / Ed25519** — signing key, OID `1.3.6.1.4.1.11591.15.1`
- **ECDH / X25519** — encryption key, OID `1.3.6.1.4.1.3029.1.5.1`

GnuPG 2.1+ supports both. SmartPGP currently only registers the six NIST/brainpool curves
(`ECCurves.java`) and only has ECDSA signing paths (`PGPKey.java:630-638`). Neither OID nor an
EdDSA signing path exists yet — this is the gap to fill.

---

## GPL v2 compliance

### Using the MIT binary as a dependency

The publicly distributed `curve25519.jar` / `Curve25519.cap` (`suut/Curve25519-JavaCard`) is
MIT-licensed. MIT is GPL v2 compatible. The combined applet system remains compliant provided:

1. SmartPGP source changes are published under GPL v2.
2. `curve25519.jar` is referenced as an external import dependency at build time, not embedded.
3. `Curve25519.cap` and `SmartPGP.cap` are delivered as separate on-card packages — customers
   load both independently via GlobalPlatformPro. The two packages never merge into a single
   binary artifact; they communicate via JavaCard's inter-package invocation mechanism.

The separate-package delivery strongly supports a "separate works" reading under GPL v2 Section 2.

### The NDA source and build provenance

The source in `Curve25519-JavaCard-Source` is NXP proprietary and must not appear in any public
repository or be used directly as a compile-time dependency of the GPL build. For reproducible
build requirements the clean pipeline is:

```
This repo's CI (flexsecure-applets):
  Curve25519-JavaCard-Source/ (private submodule, NDA-covered)
  → build → curve25519.jar + Curve25519.cap
  → pass jar path to SmartPGP ant build

  SmartPGP/ (GPL v2 fork)
  + curve25519.jar (just built above, MIT-licensed, import-only, not embedded)
  → build → SmartPGP-full.cap

Customer receives:
  SmartPGP-full.cap   (GPL v2, full source published in SmartPGP fork)
  Curve25519.cap      (MIT binary, built from source for provenance)
```

Third-party users of the SmartPGP fork who do not have access to the private source can
substitute the publicly available pre-built jar from `suut/Curve25519-JavaCard` to build
the full variant themselves.

The MIT binary is the license boundary between the GPL-covered applet and the NDA-covered
implementation. SmartPGP's "complete corresponding source" is its own GPL source only.

---

## Repository structure

```
flexsecure-applets/
  applets/
    SmartPGP/                     ← public submodule: fork of ANSSI-FR/SmartPGP
    Curve25519-JavaCard/          ← public submodule: suut/Curve25519-JavaCard (binary + jar)
    Curve25519-JavaCard-Source/   ← private submodule: NDA source (not published)
```

`.gitmodules` will list the private submodule URL publicly (the URL is visible, the contents are
not). CI accesses it via deploy key / token. The private submodule feeds only the first pipeline
stage; it is never a direct input to the GPL build.

---

## Curve25519 library API summary

From `suut/Curve25519-JavaCard` README. Objects allocated with `new`; stateless once created.

```java
// Key types
Curve25519KeyBuilder.ALG_TYPE_EDDSA_PRIVATE   = (byte) -127
Curve25519KeyBuilder.ALG_TYPE_EDDSA_PUBLIC    = (byte) -128
Curve25519KeyBuilder.ALG_TYPE_X25519_PRIVATE  = (byte) -125
Curve25519KeyBuilder.ALG_TYPE_X25519_PUBLIC   = (byte) -126

// Key generation
Curve25519KeyBuilder.buildKey(byte algo, byte memoryType) throws CryptoException
Curve25519KeyBuilder.genKeyPair(PrivateKey priv, PublicKey pub) throws CryptoException

// Signing (EdDSA)
new Curve25519Signature().sign(priv, inBuf, inOff, inLen, outBuf, outOff)       → short (sig length)
new Curve25519Signature().verify(pub, inBuf, inOff, inLen, sigBuf, sigOff, sigLen) → boolean

// Key agreement (X25519)
new Curve25519KeyAgreement().keyExchange(priv, pub, outBuf, outOff) throws CryptoException

// Keys use little-endian byte order (endian conversion handled inside the library)
```

Performance on J3R452: EdDSA sign ~220 ms, X25519 key exchange ~50 ms.

---

## Build variants

Two binaries are produced from one source tree via an ant property:

| Variant | Command | Installs on |
|---------|---------|-------------|
| `SmartPGP-full.cap` | `ant -Dcurve25519.jar=<path>` | NXP JCOP J3R452 only (requires `Curve25519.cap` pre-loaded) |
| `SmartPGP-base.cap` | `ant` (no flag) | Any JavaCard hardware |

The `curve25519.jar` property controls both the compile-time import and the conditional
inclusion of Ed25519/X25519 code via `#ifdef`-style ant/Java source patterns. When the
property is absent the Ed25519/X25519 key types are simply not registered and any attempt
to set them returns `SW_WRONG_DATA`.

In this repo's CI the jar is produced by the Curve25519-JavaCard-Source build step and its
path is passed directly to SmartPGP's ant invocation. Third-party users of the SmartPGP fork
can point the property at the pre-built jar from `suut/Curve25519-JavaCard`.

---

## Implementation work needed in SmartPGP fork

1. **`ECCurves.java`** — conditionally register Ed25519 (OID `1.3.6.1.4.1.11591.15.1`) and
   X25519 (OID `1.3.6.1.4.1.3029.1.5.1`) when building the full variant.

2. **`PGPKey.java`** — add `isEdDSA()` / `isX25519()` predicates mirroring the existing
   `isRSA()` / `isEC()` pattern; add EdDSA signing path alongside the existing ECDSA paths
   at `:630`; add X25519 key agreement path in the decrypt/decipher flow. Guard both with
   the build flag.

3. **`SmartPGPApplet.java`** — wire EdDSA signing and X25519 key agreement into the existing
   command dispatch paths, guarded by the build flag.

4. **`Constants.java`** — add the two new OIDs, guarded by the build flag.

5. **`build.xml`** — conditionalize `<import jar="curve25519.jar" />` on the property being
   set; use ant `<condition>` / `<available>` to detect it and pass a flag into the Java
   compiler (e.g. via a generated `Constants.java` boolean or a compiler `-source` define).
