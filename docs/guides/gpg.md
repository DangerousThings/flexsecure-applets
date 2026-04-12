# GPG Smartcard support

GPG supports OpenPGP smartcards, and has several useful features that can be integrated with a javacard like the flexsecure via an OpenPGP applet.  
This guide explains how to work with smartcards in GPG, and set up a few of the common use cases for it.

## Where to find your GPG config directory

This guide will provide lines that can be added to certain config files for GPG. if you are not sure where to find this directory, it is commonly located in these places:

### Windows

On Windows systems, the gpg config is typically located at `%APPDATA%\gnupg`

### Linux, MacOS, And other Unix-Likes

The GPG config directory is typically found in your home directory as `.gnupg`

## Notes on using GPG with smartcards

GPG ships its own module for handling smartcards, `scdaemon`, that may conflict with other software. if you encounter an issue where after running GPG, other softrware cannot access your smartcard, add the following lines to `scdaemon.conf` in your gpg config directory.

```text
disable-ccid
pcsc-shared
```

## Importing your public keys to GPG from a smartcard

In order to use GPG with the keys on a smartcard, you will need to use a few commands to grab the public keys, and then generate keystubs telling GPG that it can use a card as the private keys. Note that GPG will have already done this for you if you're using the machine the keys were generated with.

### Getting the public keys

GPG will automatically add the public keys to your keyring when you run `gpg --card-status`

### Getting keystubs

To get private key stubs from a smartcard, run `gpg --card-edit`, and then run `fetch` in the card edit prompt.

## Signing your Git commits via GPG

Git has support for using GPG to sign any code changes you make. To enable this support, run the following commands:

```bash
# Run this and find the key ID for the key you want to use.
gpg --list-secret-keys --keyid-format=long

# Replace <KEY_ID> with the ID you found earlier
git config --global user.signingkey <KEY_ID>

# Set Git to require GPG signing by default
git config --global commit.gpgsign true
```

### Adding your public key to a git host

For your commits to show as verified on your git host of choice, you will need to associate the public keys with your account. For Github, go to settings, then "SSH and GPG keys", and click "New GPG key". copy/paste the results of `gpg --armor --export <KEY_ID>` into the box and save it.
