# Challenge-Response using HMAC-SHA1

HMAC-SHA1 challenge-response provides a mechanism for two systems to ensure bilateral knowledge of a secret, without disclosing or transmitting the secret.

This applet is compatible to the Yubikey-style protocol, supported by e.g. KeePassXC.

## Applet Information

- Repository: https://github.com/DangerousThings/flexsecure-ykhmac (which is a fork of https://github.com/arekinath/YkOtpApplet. The fork fixes some bugs.).
- Binary name: `YkHMACApplet.cap`
- Download: https://github.com/DangerousThings/flexsecure-applets/releases
- AID: `A0:00:00:05:27:20:01`, Package: `A0:00:00:05:27:20`
- Storage requirements:
  - Persistent: `3204` bytes
  - Transient reset: `240` bytes
  - Transient deselect: `128` bytes

## Compiling the Applet Yourself

Setup your environment as described in *JavaCard Development Setup* .

Use git to clone the sources recursively, and change into the directory. Make sure the submodule in `/sdks` is checked out. To compile, run `ant dist`.

## Installing the Applet

Use GlobalPlatformPro (GPP) from https://github.com/martinpaljak/GlobalPlatformPro/releases to install the applet:

```
gp -install YkHMACApplet.cap
```

Listing the applets using `gp --list` should print something like this:

```
APP: A0000005272001 (SELECTABLE)
     Parent:  A000000151000000
     From:    A00000052720

PKG: A00000052720 (LOADED)
     Parent:  A000000151000000
     Version: 1.0
     Applet:  A0000005272001
```

## Using the Applet

This applet behaves the same way as the challenge-response functionality on a Yubikey. However, it cannot be initialized using the Yubikey Personalization GUI tools, because these require a USB connection. Instead, various other tools can be used.

First of all, make sure no YubiKeys are connected to your PC, or it might be overwritten if you are not careful.

Second, make sure to keep a backup of your secret key somewhere.

You can use the yubikey-manager CLI tool (`ykman`) to interface with the applet. You have to specify your reader using the `-r` flag (use `ykman list -r` to get a list of readers). Replace `SECRET` with a 40 character (20 byte) hexadecimal secret:

```
ykman -r 'READER' otp chalresp -f 1 SECRET
```

Use the `-f` flag to specify the slot (1 or 2).

You can also use the `yktool.jar` utility (Download from https://github.com/DangerousThings/flexsecure-applets/releases/). Take care of the string encoding on your operating system, this command is for Linux:

```
echo SECRET | java -jar yktool.jar program hmac 1 -x -X
```

Again, the `1` specifies the key slot number.

### Manual Challenge-Response

For testing, you can issue a challenge and get a response. Replace `CHALLENGE` with a 64 character (32 byte) hexadecimal challenge:

```
ykman -r 'READER' otp calculate 1 CHALLENGE
```

You can also use `yktool.jar`:

```
printf CHALLENGE | java -jar yktool.jar hmac 1 -x -X
```

If everything is encoded correctly, the commands should give the same response.

### Usage with KeePassXC

Thanks to a PR by me (https://github.com/keepassxreboot/keepassxc/pull/6895, https://github.com/keepassxreboot/keepassxc/pull/6766) KeePassXC is able to interface with this applet and Yubikeys via NFC using any compatible reader. This work on Windows, Linux and Mac.

To add a Yubikey as protection to your Database, refer to the KeePassXC documentation (or just look at the UI).

### Usage with ykdroid

The `ykdroid` Android library implements this protocol, and provides it to apps like KeePass2Android. In these apps, make sure to select *Password + Challenge-Response for KeePass XC* as decryption method (if you use KeePassXC with the same Database).

## Sources and Further Reading

- https://keepassxc.org/
- https://en.wikipedia.org/wiki/HMAC
- https://chrz.de/2021/12/22/nfc-hacking-part-1-authentication-systems-security/
- https://github.com/DangerousThings/flexsecure-ykhmac
- https://github.com/arekinath/yktool
- http://www.average.org/chal-resp-auth/
- https://crypto.stackexchange.com/questions/26510/why-is-hmac-sha1-still-considered-secure
- https://developers.yubico.com/yubikey-manager/
- https://github.com/arekinath/yktool
- https://github.com/PhilippC/keepass2android
- https://github.com/pp3345/ykDroid
- https://play.google.com/store/apps/details?id=keepass2android.keepass2android_nonet
- https://play.google.com/store/apps/details?id=net.pp3345.ykdroid

Improve this document: https://github.com/DangerousThings/flexsecure-applets/tree/master/docs
