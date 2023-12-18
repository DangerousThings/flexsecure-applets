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

    print('Patching file ' + args.patch + ' using the applet version from ' + args.source + ' and the additional build version ' + version)
    
    if(not os.path.isfile(args.source)):
        print('error: source file ' + args.source + 'does not exist')
        exit(1)
    
    # Parse version source file
    _, ext = os.path.splitext(args.source)
    with open(args.source, 'r') as f:
        config = f.read()
    if(ext == '.xml'):
        # Ant XML file
        matches = re.findall("cap.*version[\s='\"]*([^\s'\"]*)", config, flags=re.DOTALL)
    elif(ext == '.gradle'):
        # Gradle config
        matches = re.findall("javacard {.*version[\s=']*([^\s']*)", config, flags=re.DOTALL)
    else:
        print('error: Unknown source file format: ' + ext)

    if(len(matches) == 0):
        print("error: Cannot find version in config file")
        exit(1)
    appversion = matches[0]
    print("info: Found source version: " + appversion)

    if(not os.path.isfile(args.patch)):
        print('error: patch file ' + args.patch + 'does not exist')
        exit(1)
