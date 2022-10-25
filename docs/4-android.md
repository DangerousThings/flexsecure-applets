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

to each of the files `/vendor/etc/libnfc-nci.conf` and `/vendor/etc/libnfc-brcm.conf` .

This requires root access.

## Sources and Further Reading

- https://github.com/microg/GmsCore
- https://microg.org/
- https://android.stackexchange.com/questions/110927/how-to-mount-system-rewritable-or-read-only-rw-ro
- https://github.com/microg/GmsCore/pulls/StarGate01
- https://github.com/NXPNFCLinux/linux_libnfc-nci/issues/116

Improve this document: https://github.com/DangerousThings/flexsecure-applets/tree/master/docs