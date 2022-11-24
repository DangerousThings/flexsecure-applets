# Required JavaCard Algorithms

The applets distributed by VivoKey and contained in this repository require hardware support for a range of cryptographic algorithms.

Not all of these algorithms are hard requirements, some applets might provide fallbacks (e.g. for `ALG_HMAC_SHA*`) or limit certain functionality instead (e.g. PGP for generating large key sizes).

## MessageDigest

- `MessageDigest.ALG_SHA` (OTP, HMAC-SHA1)
- `MessageDigest.ALG_SHA_224` (OTP)
- `MessageDigest.ALG_SHA_256` (OTP, BIP32, FIDO2)
- `MessageDigest.ALG_SHA_512` (BIP32)

## Cipher

- `Cipher.ALG_AES_CBC_ISO9797_M2` (BIP32)
- `Cipher.ALG_AES_BLOCK_128_CBC_NOPAD` (U2F, PGP, BIP32)
- `Cipher.ALG_AES_BLOCK_128_ECB_NOPAD` (Tesla)  
- `Cipher.ALG_RSA_PKCS1` (FIDO2, PGP)

## Signature

- `Signature.ALG_AES_MAC_128_NOPAD` (BIP32)
- `Signature.ALG_RSA_SHA_256_PKCS1`(FIDO2)
- `Signature.ALG_RSA_SHA_256_PKCS1_PSS`(FIDO2)
- `Signature.ALG_ECDSA_SHA` (PGP)
- `Signature.ALG_ECDSA_SHA_224` (PGP)
- `Signature.ALG_ECDSA_SHA_256` (BIP32, U2F, FIDO2, PGP)
- `Signature.ALG_ECDSA_SHA_384` (PGP)
- `Signature.ALG_ECDSA_SHA_512` (PGP)
- `Signature.ALG_HMAC_SHA1`(HMAC-SHA1)
- `Signature.ALG_HMAC_SHA_512` (BIP32)

## KeyAgreement

- `KeyAgreement.ALG_EC_SVDP_DH_PLAIN` (BIP32, PGP)
- `KeyAgreement.ALG_EC_SVDP_DH_PLAIN_XY` (BIP32)
- `KeyAgreement.ALG_EC_SVDP_DH` (Tesla)

## KeyPair generation

- `KeyPair.ALG_EC_FP`, size = `256` (BIP32, Tesla, FIDO2)
- `KeyPair.ALG_RSA_CRT`, size =`2048` (FIDO2)

## KeyBuilder

- `KeyBuilder.ALG_TYPE_AES`, size = `128, 256` (Tesla, U2F)
- `KeyBuilder.TYPE_AES`, size = `128, 256` (PGP)
- `KeyBuilder.TYPE_HMAC_TRANSIENT_DESELECT`, size = `256` (BIP32)
- `KeyBuilder.TYPE_HMAC_TRANSIENT_RESET`, size = `64` (HMAC-SHA1)
- `KeyBuilder.TYPE_AES_TRANSIENT_DESELECT`, size = `256` (BIP32)
- `KeyBuilder.TYPE_EC_FP_PRIVATE`, size = `256, (384, 512, 521)` (BIP32, U2F, PGP, FIDO2)
- `KeyBuilder.TYPE_EC_FP_PUBLIC`, size = `256, (384, 512, 521)` (BIP32, U2F, PGP)
- `KeyBuilder.ALG_TYPE_EC_FP_PRIVATE`, size = `256` (FIDO2)
- `KeyBuilder.ALG_TYPE_EC_FP_PUBLIC`, size = `256` (FIDO2)
- `KeyBuilder.TYPE_EC_FP_PRIVATE_TRANSIENT_DESELECT`, size = `256` (U2F)
- `KeyBuilder.TYPE_EC_FP_PRIVATE_TRANSIENT_RESET`, size = `256` (U2F)
- `KeyBuilder.TYPE_RSA_CRT_PRIVATE`, size = `2048 (3072, 4096)` (PGP)
- `KeyBuilder.TYPE_RSA_PUBLIC`, size = `2048 (3072, 4096)` (PGP)

## RandomData

- `RandomData.ALG_PSEUDO_RANDOM` (OTP)
- `RandomData.ALG_SECURE_RANDOM` (BIP32, U2F, FIDO2, HMAC-SHA1)

## Sources and Further Reading

- https://docs.oracle.com/javase/7/docs/api/javax/crypto/package-summary.html

Improve this document: https://github.com/DangerousThings/flexsecure-applets/tree/master/docs
