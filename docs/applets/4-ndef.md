# Storing Data using NDEF

NDEF (NFC Data Exchange Format) is a data format used to store structured data.

## Applet Information

- Repository: https://github.com/OpenJavaCard/openjavacard-ndef
- Binary name: `openjavacard-ndef-full.cap` and `openjavacard-ndef-tiny.cap`
- Download: https://github.com/StarGate01/flexsecure-applets/releases
- AID: `D2:76:00:00:85:01:01`, Package: `D2:76:00:00:85`

## Compiling the Applet Yourself

Setup your environment as described in *JavaCard Development Setup* .

Use git to clone the sources, and change into the directory. To compile, run `ant -DJAVACARD_HOME=<sdks>/jc222_kit build`, replacing `<sdks>` with the path to your JavaCard SDKs.

The build definition produces various versions of the applet, the most interesting ones are `full`, which is a read-write enabled version, and `tiny`, which is a read-only version with static data.

## Installing the Applet

To install the applet to your card, you have to pass along some configuration data.

Use GlobalPlatformPro (GPP) from https://github.com/martinpaljak/GlobalPlatformPro/releases to install the applet:

To install the `full` variant with 2KB re-writeable storage:

```
gp -install openjavacard-ndef-full.cap -create D2760000850101 -params 8102000082020800
```

The TLV configuration format has a few options, for the specification see the openjavacard-ndef documentation at https://github.com/OpenJavaCard/openjavacard-ndef/blob/master/doc/install.md .

To install the `tiny` variant with the static URL "https://chrz.de":

```
gp -install openjavacard-ndef-tiny.cap -create D2760000850101 -params d90108015531046368727a2e6465
```

You can generate the parameter data for the `tiny` variant using a few lines of Python 3 and the `ndeflib` Pip module:

```python
import ndef
record = ndef.Record('urn:nfc:wkt:U', '1', b'\x04chrz.de')
print((b''.join((ndef.message_encoder([ record ])))).hex())
```

Check the documentation at https://ndeflib.readthedocs.io/en/latest/ndef.html#record-class . Make sure your data has a maximum size of about 200 bytes.

Listing the applets using `gp --list` should print something like this:

```
APP: D2760000850101 (SELECTABLE)
     Parent:  A000000151000000
     From:    D276000177100211030001

PKG: D276000177100211030001 (LOADED)
     Parent:  A000000151000000
     Version: 0.0
     Applet:  D27600017710021103000101
```

For more options, see the openjavacard-ndef documentation.

## Using the Applet

NDEF is widely supported by most smartphones. To write data to a re-writeable tag, I recommend using NFC Tools Pro an Android, but most apps should be compatible. 

On PC, you can use the `pcsc_ndef.py` tool from https://github.com/Giraut/pcsc-ndef, you have to specify your reader using the `-r` flag. Substitute `PAYLOAD` for the data you want to write:

```
echo PAYLOAD | python3 pcsc_ndef.py -r "READER" -t 4 write

python3 pcsc_ndef.py -r "READER" -t 4 read
```

## Sources and Further Reading

- https://learn.adafruit.com/adafruit-pn532-rfid-nfc/ndef
- https://developer.nordicsemi.com/nRF_Connect_SDK/doc/1.0.0/nrf/include/nfc/ndef/nfc.html
- http://sweet.ua.pt/andre.zuquete/Aulas/IRFID/11-12/docs/NFC%20Data%20Exchange%20Format%20(NDEF).pdf
- https://www.netes.com.tr/netes/dosyalar/dosya/B6159F60458582512B16EF1263ADE707.pdf
- https://github.com/OpenJavaCard/openjavacard-ndef/tree/master/doc
- https://github.com/Giraut/pcsc-ndef
- https://github.com/nfcpy/ndeflib
- https://ndeflib.readthedocs.io/en/latest
- https://play.google.com/store/apps/details?id=com.wakdev.nfctools.pro

Improve this document: https://github.com/StarGate01/flexsecure-applets/tree/master/docs