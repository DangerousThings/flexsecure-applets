# Android Problems and Solutions

Android has some particularities concerning NFC.

## FIDO requires Security Manager

FIDO keys are handled by a Google Services component, which is absent on FOSS (e.g. Lineage) Android builds. Use MicroG instead, which implements a security manager and FIDO adapter since version `v0.2.25.223616` . I contributed a few patches to ensure smooth operation, make sure to use at least version `v0.2.26.223616`.

## Maximum NFC Transceive Length

On some Android ROMS, the NFC driver is configured improperly, which limits the size of data packets that can be exchanged. FIDO2 requires very large packets if no chained fragmentation is used (~1KB).

To change the configuration, add the line

```
ISO_DEP_MAX_TRANSCEIVE=0xFEFF
```

to each of the files `/vendor/etc/libnfc-nci.conf` and `/vendor/etc/libnfc-brcm.conf` (and any other files you find like e.g. `libnfc-nxp.conf`).

This requires root access.

## Google Services

The proprietary Google Services security manager does not implement support for FIDO2, only U2F (time of writing: October 2022). The FIDO2 applet is backwards-compatible to U2F.

## Sources and Further Reading

- https://github.com/microg/GmsCore
- https://microg.org/
- https://android.stackexchange.com/questions/110927/how-to-mount-system-rewritable-or-read-only-rw-ro
- https://github.com/microg/GmsCore/pulls/StarGate01
- https://github.com/NXPNFCLinux/linux_libnfc-nci/issues/116
- https://groups.google.com/a/fidoalliance.org/g/fido-dev/c/H_32sr1STAg

Improve this document: https://github.com/DangerousThings/flexSecure-applets/tree/master/docs
