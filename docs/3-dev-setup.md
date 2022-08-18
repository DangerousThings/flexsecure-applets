# JavaCard Development Setup

If you want to compile applets from source, you need to install a few requirements. These instructions are for Linux, but it should work on Windows as well (using Docker or maybe WSL, see below).

## Local Development

You need to install a few software packages.

- JavaCard Development Kit 3.0.4 from [Oracle](https://www.oracle.com/java/technologies/javacard-downloads.html), or from the [GitHub mirror](https://github.com/martinpaljak/oracle_javacard_sdks).
- Apache Ant from the [website](https://ant.apache.org/) or your package manager.
- Java Development Kit 8 from [Oracle](https://www.oracle.com/de/java/technologies/javase/javase8u211-later-archive-downloads.html), or even better from [OpenJDK](https://openjdk.org/), available via your package manager.

For Ubuntu, the packages are called `ant` and `openjdk-8-jdk`. You might have to switch to the JDK using `update-alternatives --set java /usr/lib/jvm/java-8-openjdk-*/jre/bin/java`.

I also recommend installing a few tools to interact with PCSC readers, e.g. `opensc`, `pcscd`, `pcsc-tools`, and `python3-pyscard` if you use Python.

### JavaCard SDKs as Submodule

Some repositories include the JavaCard SDKs as a submodule. You can use either these submodules or your own download. Make sure to clone the repositories using `git clone --recursive` to clone the submodules as well, or make sure to initialize the submodule after cloning.

## Testing and Emulation

You can emulate and debug your applet locally by simulating a PCSC reader and running your applet in a virtual environment. This requires you to use Linux.

### Virtual Reader

Install `pcscd`, `pcsc-tools`, `opensc` and `vsmartcard-vpcd` from your package manager.

Make sure the virtual reader shows up when running `pcsc_scan -r` or `opensc-tool -lr`:

```
pcsc_scan -r

0: Virtual PCD 00 00
1: Virtual PCD 00 01
```

```
opensc-tool -l

# Detected readers (pcsc)
Nr.  Card  Features  Name
0    Yes             Virtual PCD 00 00
1    No              Virtual PCD 00 01
```

### Applet Emulation

Clone `jcardsim` from https://github.com/DangerousThings/jcardsim using git. To emulate the compiled applet, run:

```
java -cp jcardsim-3.0.5-SNAPSHOT.jar:TARGET com.licel.jcardsim.remote.VSmartCard CONFIG.cfg
```

Replace `TARGET` with the relative path to the directory containing the compiled class files of your applet, e.g. `./target`. Replace `CONFIG.cfg` with the path to your jcardsim configuration file. This file looks like this:

```
com.licel.jcardsim.card.applet.0.AID=YOURAID
com.licel.jcardsim.card.applet.0.Class=your.main.ClassName
com.licel.jcardsim.card.ATR=YOURATR
com.licel.jcardsim.vsmartcard.host=localhost
com.licel.jcardsim.vsmartcard.port=35963
```

Replace `YOURAID` with the AID you want the applet to have, e.g. `A0000005272001`. Replace `your.main.ClassName` with the class name of the main class, e.g. `com.vivokey.ykhmac.YkHMACApplet`. Replace `ATR` with the answer to reset to emulate, e.g. `3B8D80018073C021C057597562694B6579F9`; look at the pcsc-tools list or some online sources (see below) to find an appropriate ATR.

### Initializing the Applet

Next, send the initial boot APDU to create the applet, using `opensc-tool` to send raw APDUs:

```
opensc-tool -r 'Virtual PCD 00 00' -s '80 b8 00 00 KK  PP  QQ QQ QQ ... 00 [RR SS SS SS ...] FF'
```

Replace `KK` with the amount of bytes after `KK`. Replace `PP` with the amount of `QQ` bytes. Replace `QQ QQ QQ ...` with the AID of the applet. If you want to pass initialization parameters, replace `RR` with the amount of `SS` bytes, and `SS SS SS ...` with the initialization data. Do not actually write the `[ ]` brackets, these just mean that the initialization section is optional. Example: `80 b8 00 00 0A  07  a0 00 00 05 27 20 01  00  FF`.

Make sure the command was successful by watching for `Received (SW1=0x90, SW2=0x00)`.

### Using the Emulated Applet

From here on, the applet should behave like a hardware card running the applet. You have to specify the correct reader (`Virtual PCD 00 00`) to access it.

Jcardsim will print a log of all APDUs, which is very helpful for debugging. You can also attach an interactive debugger to the emulator, although exceptions from your applet code will be printed by Jcardsim by default.

To "eject" the card, just stop the Jcardsim process.

## Docker Container

If you do not want to clutter your system, or don't have a compatible Linux system, you can use a pre-made Docker container for compilation. Install Docker, and use the image at https://hub.docker.com/r/stargate01/smartcard-ci . You can find the source Dockerfile at https://github.com/DangerousThings/smartcard-ci . This image is also used to compile the applets distributed via https://github.com/DangerousThings/flexsecure-applets/releases .

To run a command inside the Docker container:

```
docker run -it --rm -v SOURCES:/app/src:rw stargate01/smartcard-ci "command"
```

Replace `SOURCES` with the absolute path to your source code directory, and `"command"` with the command you want to run.

You can look at the compilation scripts in https://github.com/DangerousThings/flexsecure-applets for reference.

The container also contains the virtual smartcard emulator, as well as the Bats test runner. You can use that to run tests against emulated applets. Refer to the test scripts in the repository.

## Sideloading

Use the GlobalPlatformPro tools (GPP) from https://github.com/martinpaljak/GlobalPlatformPro/releases to load the compiled applets onto a card. Refer to the GPP documentation for details.

For Fidesmo-deployed cards, use the `fdsm` tool from https://github.com/fidesmo/fdsm/releases to sign and sideload your applet. Refer to the Fidesmo developer documentation for details.

Do not remove the management applet package (`A0000001515350`), or security controller (`A000000151000000`). They are part of the operating system.

## Sources and Further Readingfdsm

- https://www.docker.com/
- https://github.com/DangerousThings/smartcard-ci/blob/master/Dockerfile
- https://github.com/DangerousThings/flexsecure-applets/tree/master/scripts
- https://frankmorgner.github.io/vsmartcard/
- https://pcsclite.apdu.fr/
- https://github.com/DangerousThings/jcardsim
- https://www.eftlab.com/knowledge-base/171-atr-list-full/
- https://github.com/LudovicRousseau/pcsc-tools/blob/master/smartcard_list.txt
- https://github.com/bats-core/bats-core
- https://github.com/martinpaljak/GlobalPlatformPro
- https://github.com/fidesmo/fdsm
- https://fidesmo.com/technology/java-card/

Improve this document: https://github.com/DangerousThings/flexsecure-applets/tree/master/docs