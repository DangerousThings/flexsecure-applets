# Mutual Authentication using VivoKey Verify

The VivoKey Verify applet, also known as *Spark 2*, provides two related but distinct features:

- **CMAC URL signatures** — a passive feature where every NFC tap produces a unique signed URL that a web server can verify against the VivoKey API.
- **Mutual authentication** — an active challenge-response protocol where a reader app cryptographically proves the chip is genuine and the chip cryptographically proves the reader is authorised.

The applet implements the `AuthenticateFirst` and `AuthenticateFirstPart2` commands of the Spark 2, adapted for JavaCard. It is factory-installed on VivoKey Apex devices via Fidesmo. The authentication key is managed by VivoKey server-side.

## Applet Information

- Repository: <https://github.com/VivoKey/apex-spark> (proprietary)
- Binary name: Not published
- AID: `A0:00:00:08:46:73:70:61:72:6B:32`, Package: `A0:00:00:08:46:73:70:61:72:6B:32`
- Fidesmo App ID: `c3e8c6c1`
- License: Proprietary

The AID suffix is the ASCII string `spark2`.

## Installation

The applet is factory-installed on VivoKey Apex devices via Fidesmo as the *Verify* app. No public install service is provided. The install parameter is 24 bytes:

| Offset | Length | Content |
| ------ | ------ | ------- |
| 0      | 8      | Unique chip ID |
| 8      | 16     | AES-128 authentication key |

## Using the Applet

### CMAC URL Signatures

Every time an NFC-enabled phone reads the chip, it is directed to a unique signed URL. The URL is of the form:

```
https://vivokey.co/<unique-id>/?sun=<UID>-<COUNTER>-<SIGNATURE>
```

For example:

```
https://vivokey.co/3c8d418757dcce5459f5b8576a5fb652/?sun=042468222F5C80-00003C-AE4F60A1AF728AB4
```

The counter is a 3-byte value stored on the chip and incremented on each tap; it cannot be rolled back.

### Verifying with the VivoKey API

The VivoKey [Verify API](https://vivokey.com/api/) validates signatures at `https://auth.vivokey.com`.

**Required headers:**

| Header          | Value |
| --------------- | ----- |
| `X-API-VIVOKEY` | Your API key |
| `Content-Type`  | `application/json` |

**POST `/validate`** — verifies the signature and returns a signed JWT on success. Submit the bare signature value or the full URL:

```json
{ "signature": "042468222F5C80-00003C-AE4F60A1AF728AB4" }
```

```json
{ "signature": "https://vivokey.co/3c8d418757dcce5459f5b8576a5fb652/?sun=042468222F5C80-00003C-AE4F60A1AF728AB4" }
```

Optional request fields:

| Key   | Description |
| ----- | ----------- |
| `aud` | Audience claim embedded into the resulting JWT |
| `cld` | Arbitrary client data string (up to 2048 characters), embedded into the JWT |

**Response fields:**

| Key      | Description |
| -------- | ----------- |
| `result` | `success`, `expired`, or `invalid` |
| `token`  | Signed authenticity JWT — only present when `result` is `success` |

The JWT `atp` claim will be `"cmac"`. You can inspect JWTs at <https://jwt.io>.

**POST `/validate.json`** — same as `/validate` but returns unsigned JSON, useful when you do not need a signed token:

```json
{
  "dev_id": "aaa1c9d1-078d-45c3-adfe-4274ccee9043",
  "atp": "cmac",
  "result": "success",
  ...
}
```

Expired signatures (e.g. when a user reloads a page) return `{"result": "expired"}` with no token. See the [NDEF applet documentation](ndef.md) for full details on the security caveats of counter-based signatures, including the stockpile attack scenario.

### Mutual Authentication Protocol

For active mutual authentication (e.g. a reader app that proves both sides are genuine), the protocol uses three APDU exchanges followed by two API calls.

**1. Select the applet**

```
00 A4 04 00 0C A0 00 00 08 46 73 70 61 72 6B 32 01
```

Response: 8-byte chip UID.

**2. AuthenticateFirst — request a challenge**

```
90 71 00 00 02 02 00 00
```

Response: 16-byte challenge `C`.

**3. POST `/challenge`** — supply the challenge and chip UID to the API; receive the pre-computed response:

Request:

```json
{ "scheme": 2, "message": "<C as hex>", "uid": "<chip UID as hex>" }
```

Response:

```json
{ "payload": "<R as hex>", "token": "<intermediate token>" }
```

Save the `token` for step 5.

**4. AuthenticateFirstPart2 — send the response**

Send the `payload` value `R` from the API:

```
90 AF 00 00 20 <R (32 bytes)> 00
```

Response: 32-byte verification value `V`.

**5. POST `/session`** — supply the chip's verification value and the token from `/challenge`; receive a signed JWT:

Request:

```json
{ "uid": "<chip UID as hex>", "response": "<V as hex>", "token": "<token from /challenge>", "cld": "<optional client data string>" }
```

Response:

```json
{ "token": "<signed JWT>" }
```

The JWT is signed with ES256. Verify it using the JWKS endpoint at `https://auth.vivokey.com/.well-known/jwks.json`. The JWT `atp` claim will be `"mutual"`. You can inspect JWTs at <https://jwt.io>.

## Sources and Further Reading

- <https://vivokey.com/api/>
- <https://auth.vivokey.com>
- <https://auth.vivokey.com/.well-known/jwks.json>
- <https://jwt.io>

Improve this document: <https://github.com/DangerousThings/flexsecure-applets/tree/master/docs>
