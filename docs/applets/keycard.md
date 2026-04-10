# BIP32 Cryptocurrency Wallet using KeyCard

The BIP32 Wallet is a distribution of the Status.im KeyCard applet. Read more at <https://status.im/secure-wallet/> and <https://keycard.tech/> .

## Applet Information

- Repository: <https://github.com/status-im/status-keycard>
- Binary name: `keycard.cap` (Gradle produces multiple CAP files; the core and cash applets are used)
- Download: <https://github.com/DangerousThings/flexsecure-applets/releases>
- AID: `A0:00:00:08:04:00:01:01:01` (core) and `A0:00:00:08:04:00:01:03:01` (cash), Package: `A0:00:00:08:04:00:01`
- Fidesmo App ID: `38ea914a`
- License: Apache v2
- Storage requirements:
   - Persistent: `16424` bytes
   - Transient reset: `1366` bytes
   - Transient deselect: `400` bytes

## Compiling the Applet Yourself

Setup your environment as described in *JavaCard Development Setup*. The build scripts in `scripts/compile/` automate the steps below.

```bash
JC_HOME=<sdks>/jc304_kit ./gradlew convertJavacard
```

## Installing the Applet

The cabinet file contains three distinct applets, of which the NDEF one is not needed. The other two (core and cash) need to be installed.

Use GlobalPlatformPro (GPP) from <https://github.com/martinpaljak/GlobalPlatformPro/releases> to install the applets:

```bash
gp -load keycard.cap

gp -package A0000008040001 -applet A000000804000101 -create A00000080400010101

gp -package A0000008040001 -applet A000000804000103 -create A00000080400010301
```

Listing the applets using `gp --list` should print something like this:

```text
APP: A00000080400010101 (SELECTABLE)
     Parent:  A000000151000000
     From:    A0000008040001
     Privs:

APP: A00000080400010301 (SELECTABLE)
     Parent:  A000000151000000
     From:    A0000008040001
     Privs:

PKG: A0000008040001 (LOADED)
     Parent:  A000000151000000
     Version: 3.1
     Applet:  A000000804000101
     Applet:  A000000804000102
     Applet:  A000000804000103
```

## Using the Applet

Keycard is supported by several wallet applications. The primary integration is [Status](https://status.im/), but the applet implements the open [Keycard API](https://keycard.tech/) and can be used with any compatible client. The [Keycard CLI](https://keycard.tech/docs/keycard-cli.html) can be used for card management from the command line.

For more information, refer to the documentation at <https://keycard.tech/docs/>.

## Sources and Further Reading

- <https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki>
- <https://keycard.tech/>
- <https://status.im/>
- <https://gist.github.com/rbnpercy/adae04c4fddeee4d324d6028ab4b4d47>
- <https://play.google.com/store/apps/details?id=im.status.ethereum>

Improve this document: <https://github.com/DangerousThings/flexsecure-applets/tree/master/docs>
