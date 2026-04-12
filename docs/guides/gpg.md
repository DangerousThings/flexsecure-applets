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

## Using GPG as an SSH agent

It is possible to use gpg to replace the default ssh agent, and then use your PGP keys for SSH authentication. This setup tends to be a bit difficult to get working correctly, and can have some security issues if you do not use sufficiently strong keys. ECDSA or EDDSA keys are suggested.

### Configuring GPG to act as an SSH agent

GPG does not enable this functionality by default. to turn it on, make the following config changes:

In `gpg-agent.conf`:

```text
enable-ssh-support
```

Add the keygrip for the desired key to the `sshcontrol` file:

```bash
# Run this and find the authentication subkey for your card, it'll have [A] after the key type and date
# Copy the keygrip from it and add that to the "sshcontrol" file in your GPG config directory
gpg -K --with-keygrip
```

Note: If you skip this step, GPG will fail silently, and the issue will be very difficult to troubleshoot.

Restart the GPG agent to apply the changes:

```bash
gpg-connect-agent killagent /bye
```

### Configure SSH to use the GPG agent

SSH will use its own ssh-agent by default. there are a few different ways to accomplish setting it to use gpg, and they are not mutually exclusive.

- Environment variables
   - These are handled by your shell. for bash or zsh, add these lines to your .bashrc or .zshrc

```text
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent
```

- SSH config
   - Only works with ssh itself and not certain ssh-related commands
   - add these lines to your `.ssh/config` file

```text
Match host * exec "gpg-connect-agent UPDATESTARTUPTTY /bye"
Host *
    IdentityAgent /run/user/1000/gnupg/S.gpg-agent.ssh
```

### Add your GPG key to remote hosts

To use a GPG key to sign into a machine, you need to have your GPG public key set as an authorized key.

To do this, copy the output of `ssh-add -L` and paste it into `.ssh/authorized_keys` on the target machine, or use the `ssh-copy-id` tool to do it automatically.
