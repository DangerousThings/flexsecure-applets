# Generating One-Time Passwords (OATH-TOTP / HOTP) 

Time-based (TOTP) and counter-based (HOTP) one-time passwords are used to generate rolling codes for two-factor authentication.

These codes are preferred over e.g. SMS codes, because the process requires no codes to be received from a server; instead all rolling codes are generated locally and cannot be intercepted.

## Applet Information

- Repository: https://github.com/StarGate01/Flex-OTP (which is a fork of https://github.com/VivoKey/Flex-OTP. The fork impersonates a Yubikey.)
- Binary name: `vivokey-otp.cap`
- Download: https://github.com/StarGate01/flexsecure-applets/releases
- AID: `A0:00:00:05:27:21:01:01`, Package: `A0:00:00:05:27:21:01`

## Compiling the Applet

Setup your environment as described in *JavaCard Development Setup* .

Use git to clone the sources recursively, and change into the directory. Make sure the submodule in `/oracle_javacard_sdks` is checked out. To compile, run `ant dist`.

## Installing the Applet

Use GlobalPlatformPro (GPP) from https://github.com/martinpaljak/GlobalPlatformPro/releases to install the applet:

```
gp -install vivokey-otp.cap
```

Listing the applets using `gp --list` should print something like this:

```
APP: A000000527210101 (SELECTABLE)
     Parent:  A000000151000000
     From:    A0000005272101

PKG: A0000005272101 (LOADED)
     Parent:  A000000151000000
     Version: 1.0
     Applet:  A000000527210101 
```

## Using the Applet

The Yubikey Authenticator tool is able to interface this applet on both Desktop and Mobile. On Desktop, you have to specify your PCSC reader in **Settings -> Advanced -> Custom Reader**.

You can also use the yubikey-manager CLI tool (`ykman`) to interface with the applet. You have to specify your reader using the `-r` flag. Refer to the documentation of that tool.

## Sources and Further Reading

- https://www.yubico.com/products/yubico-authenticator/
- https://en.wikipedia.org/wiki/Time-based_one-time_password
- https://www.yubico.com/resources/glossary/oath-totp/
- https://www.yubico.com/resources/glossary/oath-hotp/
- https://stefansundin.github.io/2fa-qr/
