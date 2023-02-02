# One-Time Passwords using OATH-TOTP/HOTP

Time-based (TOTP) and counter-based (HOTP) one-time passwords are used to generate rolling codes for two-factor authentication.

These codes are preferred over e.g. SMS codes, because the process requires no codes to be received from a server; instead all rolling codes are generated locally and cannot be intercepted.

## Applet Information

- Repository: https://github.com/VivoKey/apex-totp
- Binary name: `vivokey-otp.cap`
- Download: https://github.com/DangerousThings/flexsecure-applets/releases
- AID: `A0:00:00:05:27:21:01:01:41:50:45:58:01`, Package: `A0:00:00:05:27:21:01:01:41:50:45:58`
- Storage requirements:
  - Persistent: `5128` bytes (`6020` with three TOTP accounts)
  - Transient reset: `2296` bytes (`2392`)
  - Transient deselect: `64` bytes

## Compiling the Applet Yourself

Setup your environment as described in *JavaCard Development Setup* .

Use git to clone the sources recursively, and change into the directory. Make sure the submodule in `/oracle_javacard_sdks` is checked out. To compile, run `ant dist`.

## Installing the Applet

Use GlobalPlatformPro (GPP) from https://github.com/martinpaljak/GlobalPlatformPro/releases to install the applet:

```
gp -install vivokey-otp.cap
```

Listing the applets using `gp --list` should print something like this:

```
APP: A0000005272101014150455801 (SELECTABLE)
     Parent:  A000000151000000
     From:    A00000052721010141504558

PKG: A00000052721010141504558 (LOADED)
     Parent:  A000000151000000
     Version: 1.1
     Applet:  A0000005272101014150455801
```

## Using the Applet

Use the VivoKey Apex Manager App to interface this applet.

The Yubikey Authenticator tool is able to interface this applet on both Desktop and Mobile as well, but it requires you to also have the HMAC-SHA1 applet installed (it does not necessarily have to be initialized with keys). On Desktop, you have to specify your PCSC reader in **Settings -> Advanced -> Custom Reader**.

You can also use the yubikey-manager CLI tool (`ykman`) to interface with the applet. You have to specify your reader using the `-r` flag (use `ykman list -r` to get a list of readers). Replace `SECRET` with a 32 character Base-32 encoded secret:

```
ykman -r 'READER' oath accounts uri "otpauth://totp/Test?secret=SECRET"

ykman -r 'READER' oath accounts code Test
```

This URI string is the same as is encoded in the usual QR codes.

## Sources and Further Reading

- https://www.yubico.com/products/yubico-authenticator/
- https://en.wikipedia.org/wiki/Time-based_one-time_password
- https://www.yubico.com/resources/glossary/oath-totp/
- https://www.yubico.com/resources/glossary/oath-hotp/
- https://stefansundin.github.io/2fa-qr/
- https://developers.yubico.com/yubikey-manager/

Improve this document: https://github.com/DangerousThings/flexsecure-applets/tree/master/docs