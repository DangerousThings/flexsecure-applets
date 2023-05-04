#!/usr/bin/env bash

ndef_check_size() {
    cd /app/tools/pcsc-ndef
    RESP=`python3 pcsc_ndef.py -r "Virtual PCD 00 00" -t4 getmax`
    [ "$RESP" == "2046" ]
}

ndef_read_write() {
    cd /app/tools/pcsc-ndef
    PAYLOAD='fHwG61CGBRM3L6ZrpGpq'
    echo $PAYLOAD | python3 pcsc_ndef.py -r "Virtual PCD 00 00" -t 4 write
    RESP=`python3 pcsc_ndef.py -r "Virtual PCD 00 00" -t 4 read`
    [ "$RESP" == "$PAYLOAD" ]
}
