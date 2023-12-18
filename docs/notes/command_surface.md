This document lists all the `INS` instruction bytes accepted by the applets linked in this repository.

The `CLA` class byte is usually `00`, `80`, `B0`, or any of these `| 10` .

## All applets

Standard ISO commands:

- `C0`: GET RESPONSE
- `A4`: SELECT

Vivokey extension:

- `F4`: GET VERSION

## apex-fido2, FIDO2Applet, and u2f-javacard

NFCCTAP 2.0 commands, apex-fido2 and FIDO2Applet only:

- `10`: MESSAGE
- `11`: GET RESPONSE
- `12`: CONTROL

U2F commands:

- `01`: REGISTER
- `02`: AUTHENTICATE
- `03`: VERSION

## apex-ndef, openjavacard-ndef, and status-keycard/NDEFApplet

T4TOP 2.0 commands:

- `B0`: READ BINARY
- `D6`: UPDATE BINARY

apex-ndef only:

- `E1`: DISABLE WRITE

## apex-spark

NTAGDNA commands:

- `71`: AUTH FIRST
- `AF`: AUTH FIRST P2

## apex-tesla

Tesla commands:

- `04`: GET PUBKEY
- `06`: GET CERT
- `07`: GET VERSIONS
- `11`: GET CHALLENGE
- `14`: GET FACTOR
- `1B`: SET INFO
- `00`, `01`, `02`, `03`, `04`, `05`, `08`, `12`, `13`, `14`, `15`: UNKNOWN

## apex-totp

Yubico OTP commands:

- `01`: PUT
- `02`: DELETE
- `03`: SET CODE
- `04`: RESET
- `05`: RENAME
- `A1`: LIST
- `A2`: CALCULATE
- `A3`: VALIDATE
- `A4`: CALCULATE ALL
- `A5`: SEND REMAINING

## flexsecure-ykhmac

Yubico HMAC commands

- `01`: API REQ
- `02`: OTP (unused)
- `03`: STATUS
- `04`: NDEF (unused)

## javacard-memory

No commands beyond applet selection

## SatochipApplet, Satodime-Applet, and Seedkeeper-Applet

Common commands:

- `2A`: SETUP
- `3C`: GET STATUS
- `3D`: CARD LABEL 
- `81`: INIT SECURE CHANNEL
- `82`: PROCESS SECURE CHANNEL
- `AD`: EXPORT AUTHENTIKEY 
- `92`: IMPORT PKI CERTIFICATE
- `93`: EXPORT PKI CERTIFICATE
- `94`: SIGN PKI CSR
- `98`: EXPORT PKI PUBKEY
- `99`: LOCK PKI
- `9A`: CHALLENGE RESPONSE PKI 

Satochip and Seedkeeper:

- `40`: CREATE PIN
- `42`: VERIFY PIN
- `44`: CHANGE PIN
- `46`: UNBLOCK PIN
- `60`: LOGOUT ALL 
- `48`: LIST PINS
- `73`: BIP32 GET AUTHENTIKEY
- `FF`: RESET TO FACTORY

Satochip-only commands:

- `32`: IMPORT KEY
- `33`: RESET KEY
- `35`: GET PUBLIC FROM PRIVATE 
- `6C`: BIP32 IMPORT SEED
- `77`: BIP32 RESET SEED
- `75`: BIP32 SET AUTHENTIKEY PUBKEY
- `6D`: BIP32 GET EXTENDED KEY
- `74`: BIP32 SET EXTENDED PUBKEY
- `6E`: SIGN MESSAGE
- `72`: SIGN SHORT MESSAGE
- `6F`: SIGN TRANSACTION
- `71`: PARSE TRANSACTION
- `76`: CRYPT TRANSACTION 2FA
- `79`: SET 2FA KEY
- `78`: RESET 2FA KEY
- `7A`: SIGN TRANSACTION HASH 
- `AC`: IMPORT ENCRYPTED SECRET
- `AA`: IMPORT TRUSTED PUBKEY
- `AB`: EXPORT TRUSTED PUBKEY

Seedkeeper-only commands:

- `A0`: GENERATE MASTERSEED
- `AE`: GENERATE 2FA SECRET 
- `A1`: IMPORT SECRET
- `A2`: EXPORT SECRET
- `A5`: RESET SECRET
- `A6`: LIST SECRET HEADERS
- `A9`: PRINT LOGS

Satodime-only commands:

- `50`: GET SATODIME STATUS 
- `51`: GET SATODIME KEYSLOT STATUS 
- `52`: SET SATODIME KEYSLOT STATUS 
- `53`: GET SATODIME UNLOCK CODE (unused)
- `55`: GET SATODIME PUBKEY  
- `56`: GET SATODIME PRIVKEY 
- `57`: SEAL SATODIME KEY  
- `58`: UNSEAL SATODIME KEY  
- `59`: RESET SATODIME KEY  
- `5A`: INITIATE SATODIME TRANSFER 

## SmartPGP

OpenPGP Card commands:

- `A5`: SELECT DATA
- `CA`: GET DATA
- `CC`: GET NEXT DATA
- `20`: VERIFY
- `24`: CHANGE REFERENCE DATA
- `2C`: RESET RETRY COUNTER
- `DA`: PUT DATA DA
- `DB`: PUT DATA DB
- `47`: GENERATE ASYMMETRIC KEY PAIR
- `2A`: PERFORM SECURITY OPERATION
- `88`: INTERNAL AUTHENTICATE
- `84`: GET CHALLENGE
- `E6`: TERMINATE DF
- `44`: ACTIVATE FILE

## status-keycard

Keycard commands:

- `F2`: GET STATUS
- `FE`: INIT
- `FD`: FACTORY RESET
- `20`: VERIFY PIN
- `21`: CHANGE PIN
- `22`: UNBLOCK PIN
- `D0`: LOAD KEY
- `D1`: DERIVE KEY
- `D2`: GENERATE MNEMONIC
- `D3`: REMOVE KEY
- `D4`: GENERATE KEY
- `C0`: SIGN
- `C1`: SET PINLESS PATH
- `C2`: EXPORT KEY
- `CA`: GET DATA
- `E2`: STORE DATA
