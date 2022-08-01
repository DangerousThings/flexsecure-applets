#!/usr/bin/env python3

import ndef

record = ndef.Record('urn:nfc:wkt:U', '1', b'\x04chrz.de')
print((b''.join((ndef.message_encoder([ record ])))).hex())
