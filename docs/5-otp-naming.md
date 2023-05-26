# OTP / OATH Applet Naming

Due to some historical decisions and industry conventions, the naming of the two-factor authentication applets is a bit confusing.

## 1. Rolling One-Time Passwords 

This applet stores a list of user accounts and generates rolling 6-digit codes for each one.

The version distributed via the VivoKey Fidesmo store should also be compatible with the Yubico Authenticator programs.

- Supported protocols: `OATH-TOTP` (RFC 6238) and `OATH-HOTP` (RFC 4226)
- Yubico calls this `OATH` (see https://docs.yubico.com/software/yubikey/tools/ykman/OATH_Commands.html)
- Repository: https://github.com/VivoKey/apex-totp
- Documentation: https://github.com/DangerousThings/flexsecure-applets/blob/master/docs/applets/2-totp-hotp.md
- Applet name: `vivokey-otp.cap`, AID: `A0:00:00:05:27:21:01:01`

## 2. Static Challenge-Response

This applet provides two key slots, which can be programmed with a static secret key.

Even though this applet implements the Yubico-compatible `HMAC-SHA1` challenge-response protocol, it does not support other slot configurations such as static `HOTP`, `NDEF`, or `YubiOTP`. For `HOTP`, use the other applet. 

- Supported protocols: `HMAC-SHA1` (RFC 2104)
- Yubico calls this `OTP` (see https://docs.yubico.com/software/yubikey/tools/ykman/OTP_Commands.html, specifically `chalresp`)
- Repository: https://github.com/DangerousThings/flexsecure-ykhmac
- Documentation: https://github.com/DangerousThings/flexsecure-applets/blob/master/docs/applets/3-hmac-sha1.md
- Applet name: `YkHMACApplet.cap`, AID: `A0:00:00:05:27:20:01:01`

## Sources and Further Reading

- https://docs.yubico.com/software/yubikey/tools/ykman/intro.html

Improve this document: https://github.com/DangerousThings/flexsecure-applets/tree/master/docs
