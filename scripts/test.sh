#!/bin/bash

# create applet data = 0x80, 0xb8, 0, 0, cmd len, aid len (byte), aid bytes, params length (byte), param, 7f (?)

echo "Setting up environment"
pcscd -f & 
sleep 2


echo "Testing vk-ykhmac"
cd /app/src/applets/vk-ykhmac
java -cp /app/tools/jcardsim/target/jcardsim-3.0.5-SNAPSHOT.jar:./target com.licel.jcardsim.remote.VSmartCard test/jcardsim.cfg > /dev/null &
JCSIM_PID=$!
sleep 2
opensc-tool -r 'Virtual PCD 00 00' -s '80 b8 00 00 0e  07  a0 00 00 05 27 20 01  05 00 00 02 F F  7f'
pcsc_scan -c

java -jar tools/yktool/yktool.jar list
echo 'b6e3f555562c894b7af13b1db37f28deff3ea89b' | java -jar tools/yktool/yktool.jar program hmac 1 -x -X
YKRES=`printf 'aaaa' | java -jar tools/yktool/yktool.jar hmac 1 -x`
echo $YKRES
if [ "$YKRES" == "72:7E:C8:E8:15:EE:C5:32:8F:9D:9C:BE:5E:F2:4E:A8:36:D7:CE:56" ]; then 
    echo "vk-ykhmac test passed"
else
    echo "vk-ykhmac test failed"
    exit 1
fi

kill $JCSIM_PID
sleep 2
pcsc_scan -c
echo ""


echo "Testing SmartPGP"
cd /app/src/applets/SmartPGP
java -cp /app/tools/jcardsim/target/jcardsim-3.0.5-SNAPSHOT.jar:./target com.licel.jcardsim.remote.VSmartCard test/jcardsim.cfg > /dev/null &
JCSIM_PID=$!
sleep 2
opensc-tool -r 'Virtual PCD 00 00' -s '80 b8 00 00 17  10  d2 76 00 01 24 01 03 04 C0 FE 00 00 00 01 00 00  05 00 00 02 F F  7f'
pcsc_scan -c

gpg --card-status
/app/src/scripts/test.gpg.expect
gpg --card-status

kill $JCSIM_PID
sleep 2
pcsc_scan -c
echo ""
