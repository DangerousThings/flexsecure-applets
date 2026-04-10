# Memory Usage Reporting using Free Memory

The Free Memory applet reports available JavaCard memory on the chip. It is used by the VivoKey Apex Manager app to display remaining storage, and can be used directly to measure memory consumption before and after installing other applets.

## Applet Information

- Repository: <https://github.com/DangerousThings/javacard-memory>
- Binary name: `javacard-memory.cap`
- Download: <https://github.com/DangerousThings/flexsecure-applets/releases>
- AID: `A0:00:00:08:46:6D:65:6D:6F:72:79:01`, Package: `A0:00:00:08:46:6D:65:6D:6F:72:79`
- Fidesmo App ID: `99848a60`
- License: MIT

## Compiling the Applet Yourself

Setup your environment as described in *JavaCard Development Setup*. The build scripts in `scripts/compile/` automate the steps below.

```bash
JC_HOME=<sdks>/jc304_kit ant dist
```

Produces `target/javacard-memory.cap`.

## Installing the Applet

Use GlobalPlatformPro (GPP) from <https://github.com/martinpaljak/GlobalPlatformPro/releases> to install the applet.

The install parameter is 8 bytes:

| Offset | Length | Content |
| ------ | ------ | ------- |
| 0      | 4      | Total persistent memory baseline in bytes (32-bit big-endian unsigned) |
| 4      | 4      | Batch ID (optional, reported via `INS_GET_BATCH`) |

The baseline is the total persistent memory available on a freshly initialised chip, before any applets are installed. This value is stored by the applet and used to compute usage percentages:

| Device               | Baseline     | Parameter  |
| -------------------- | ------------ | ---------- |
| flexSecure (NXP P71) | 167736 bytes | `00028F38` |
| VivoKey Apex Flex    | 84336 bytes  | `00014970` |

```bash
# flexSecure
gp --install javacard-memory.cap --params 00028F38

# Apex Flex (Fidesmo default)
gp --install javacard-memory.cap --params 00014970
```

If no parameter is given, the applet defaults to the flexSecure baseline (`00028F38`).

## Using the Applet

### Reading Memory Usage

On every SELECT, the applet returns 12 bytes:

| Offset | Length | Content |
| ------ | ------ | ------- |
| 0      | 4      | Available persistent memory in bytes (32-bit big-endian) |
| 4      | 4      | Total persistent memory baseline in bytes (32-bit big-endian) |
| 8      | 2      | Available transient reset memory in bytes |
| 10     | 2      | Available transient deselect memory in bytes |

### Reading the Batch ID

Send `INS_GET_BATCH` (`00 01 00 00 00`) after selection to retrieve the 4-byte batch ID stored at install time.

### Using measure.py

A PC/SC measurement script is provided in `applets/javacard-memory/measure.py`. Install Python 3 and `pyscard`, then run:

```bash
# List available readers
./measure.py -l

# Read memory from the default reader
./measure.py

# Read memory from a specific reader
./measure.py -r 1
```

The script selects the applet, parses the response, and prints a human-readable memory report including percentage free for persistent and transient memory. It also queries the batch ID and applet version.

The recommended workflow is to run `measure.py` before and after installing an applet to determine its exact memory footprint.

## Sources and Further Reading

- <https://github.com/DangerousThings/javacard-memory>

Improve this document: <https://github.com/DangerousThings/flexsecure-applets/tree/master/docs>
