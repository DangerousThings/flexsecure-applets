# Secure secret vault via SeedKeeper

SeedKeeper is an applet intended for storing your crypto wallet seeds, but it is generalized to hold passwords and arbitrary data.

## Applet Information

- Repository: <https://github.com/Toporin/Seedkeeper-Applet>
- Binary name: `SeedKeeper-v0.2-0.1.cap`
- Download: <https://github.com/Toporin/Seedkeeper-Applet/releases>
- AID: `53:65:65:64:4B:65:65:70:65:72:00`, Package: `53:65:65:64:4B:65:65:70:65:72`
- Storage requirements:
   - Persistent: 18641 bytes
   - Installed: Configurable, see below

## Installing the Applet

The cabinet file contains one applet. you can optionally install a version with ndef support, but this isn't needed for it to function normally and just makes android open the seedkeeper app by default when the card is presented. It is recommended that ndef functionality be provided separately for the sake of flexibility.  
SeedKeeper supports a variable container size via passing the size as an installation parameter. to install it with 4kb, you'd pass 0x1000, or you can pass 0x4000 for 16kb. the maximum it supports is 32kb.

Use GlobalPlatformPro (GPP) from <https://github.com/martinpaljak/GlobalPlatformPro/releases> to install the applet:

```bash
gp --install SeedKeeper-v0.2-0.1.cap --params 4000 #install with 16kb of vault space
```

## Using the applet

SeedKeeper is supported by mobile apps for iOS or Android, and the Satochip desktop app for Windows, Mac and Linux.
For the desktop apps, any standard PC/SC nfc reader will work to interface with the card.

Both programs support all features of the applet.
After installing the applet and reading it for the first time, you will be asked to set up the card by providing a pin code for it. after that, you can use the software to either generate a secret on-card, or import one you already have. SeedKeeper natively supports mnemonic seedphrases, passwords, and plain unformatted data as secret types. once a card has been loaded up, you can use the software to make backup copies of the data to other cards..
