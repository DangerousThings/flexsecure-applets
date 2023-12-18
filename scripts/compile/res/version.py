#!/usr/bin/env python3

import argparse, os, re

if __name__ == '__main__':
    # Parse CLI arguments
    parser = argparse.ArgumentParser(description = 'FlexSecure-Applets version patching tool')
    parser.add_argument('-s', '--source', nargs='?', dest='source', type=str, 
        const='', default='', help='File to read the applet version from')
    parser.add_argument('-p', '--patch', nargs='?', dest='patch', type=str, 
        const='', default='', help='File to patch')
    parser.add_argument('-v', '--version', nargs='?', dest='version', type=str, 
        const='255.255.255', default='255.255.255', help='Build version to encode')
    args = parser.parse_args()
    version = args.version.strip('v')
    print('info: Patching file: ' + args.patch)
    print('info: Applet version from: ' + args.source)
    print('info: Additional build version: ' + version)
    
    # Parse version source file
    _, ext = os.path.splitext(args.source)
    if(not os.path.isfile(args.source)):
        print('error: source file ' + args.source + 'does not exist')
        exit(1)
    with open(args.source, 'r') as f:
        config = f.read()
    if(ext == '.xml'):
        # Ant XML file
        matches = re.search("cap.*version[\s='\"]*([^\s'\"]*)", config, flags=re.DOTALL)
    elif(ext == '.gradle'):
        # Gradle config
        matches = re.search("javacard {.*version[\s=']*([^\s']*)", config, flags=re.DOTALL)
    else:
        print('error: Unknown source file format: ' + ext)
    if(matches == None):
        print("error: Cannot find version in config file")
        exit(1)
    appversion = matches.group(1)
    print("info: Found applet version: " + appversion)

    # Generate patch
    appversion = appversion.split('.')
    version = version.split('.')
    patch = '''
        byte[] ver_buf = apdu.getBuffer();
        if(ver_buf[ISO7816.OFFSET_INS] == (byte) 0xF4 && ver_buf[ISO7816.OFFSET_P1] == (byte) 0x99 && ver_buf[ISO7816.OFFSET_P2] == (byte) 0x99) {{
            short ver_le = apdu.setOutgoing();
            short ver_len = (short) 5;
            ver_len = ver_le > (short) 0 ? (ver_le > ver_len ? ver_len : ver_le) : ver_len;
            ver_buf[0] = (byte) {};
            ver_buf[1] = (byte) {};
            ver_buf[2] = (byte) {};
            ver_buf[3] = (byte) {};
            ver_buf[4] = (byte) {};
            apdu.setOutgoingLength(ver_len);
            apdu.sendBytes((short) 0, ver_len);
            ver_buf = null;
            return;
        }} else {{
            ver_buf = null;
        }}
    '''.format(appversion[0], appversion[1], version[0], version[1], version[2])

    # Find patch location and apply patch
    if(not os.path.isfile(args.patch)):
        print('error: patch file ' + args.patch + 'does not exist')
        exit(1)
    with open(args.patch, 'r') as f:
        patchtarget = f.read()
    match = re.search("void\s*process\s*\((?:final)?\s*APDU apdu\)\s*(?:throws ISOException)?\s*{", patchtarget, flags=re.DOTALL)
    if(match == None):
        print("error: Cannot find process method in patch file")
        exit(1)
    offset = match.end()
    patchtarget = patchtarget[:offset] + patch + patchtarget[offset:]
    with open(args.patch, 'w') as f:
        f.write(patchtarget)

    print("info: Done patching")
