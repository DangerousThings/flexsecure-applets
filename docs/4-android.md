# Android Problems and Solutions

Android has some particularities concerning NFC.

## FIDO requires Security Manager

FIDO keys are handled by a Google Services component, which is absent on FOSS (e.g. Lineage) Android builds. Use MicroG instead, which implements a security manager and FIDO adapter since version `v0.2.25.223616` . Make sure to also apply my two patches (https://github.com/microg/GmsCore/pulls/StarGate01) for smooth operation. These patches will be eventually released in a new version of MicroG.

## Maximum NFC Transceive Length

On some Android ROMS, the NFC driver is configured improperly, which limits the size of data packets that can be exchanged. FIDO2 requires very large packets (~1KB).

To change the configuration, add the line

```
ISO_DEP_MAX_TRANSCEIVE=0xFEFF 	 	
```

to each of the files `/vendor/etc/libnfc-nci.conf` and `/vendor/etc/libnfc-brcm.conf` (and any other files you find like e.g. `libnfc-nxp.conf`).

This requires root access.

## Google Services

The proprietary Google Services security manager does not implement support for FIDO2, only U2F (time of writing: October 2022). So you have to use the U2F applet or wait until the U2F functionality has been integrated into the FIDO2 applet as a fallback.

## Sources and Further Reading

- https://github.com/microg/GmsCore
- https://microg.org/
- https://android.stackexchange.com/questions/110927/how-to-mount-system-rewritable-or-read-only-rw-ro
- https://github.com/microg/GmsCore/pulls/StarGate01
- https://github.com/NXPNFCLinux/linux_libnfc-nci/issues/116
- https://groups.google.com/a/fidoalliance.org/g/fido-dev/c/H_32sr1STAg

Improve this document: https://github.com/DangerousThings/flexsecure-applets/tree/master/docs