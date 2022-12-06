# flexSecure vs. Apex Flex

Please read the [*Introduction to the JavaCard Ecosystem*](https://github.com/DangerousThings/flexSecure-applets/blob/master/docs/1-technology.md) first, to understand the technical differences.

## Target Audience

If you want an easy-to-use implant with an existing ecosystem, a mobile app-store and the potential payment functionality in the future, then the [Apex Flex](https://dngr.us/apex-flex) is for you.

If you want full offline control over your hardware and keys, the maximum possible storage and memory, and are not afraid of using the console and reading into the technical documentation, then the [flexSecure](https://dngr.us/flexsecure) is for you.

## The NXP P71 Chip

The specification of the chip used in the flexSecure and Apex Flex (with a differing configuration, see below) is as follows:

- Manufacturer: NXP Semiconductors
- Series: SmartMX3 Secure and Flexible Microcontroller
- Model: `P71D321`
- Operating system: `JCOP4`
- Software interface: `SCP02` GlobalPlatform `2.2.1` and `2.3` / Java Card `3.0.4` Classic and `3.0.5` Classic
- Variant: J3R200 (`200KB` EEPROM)
- Package: MOB10 ultra-thin (chip: `5 mm * 5 mm`, total: `5 mm * 8 mm`, thickness: `0.1 mm`) punched from `35 mm` tape reels
- Hardware interface: Contactless (NFC `13.56 MHz`, ISO/IEC 14443 Type A) only
- Capacitance: `56 pF`
- Configuration: "MIFARE Plus EV1 in classic mode 4K applet" removed, leaves `>= 164K` EEPROM, `>= 4KB` RAM usable (for details, see below)
- GlobalPlatform key: `404142434445464748494a4b4c4d4e4f` (default test key)
- Supported algorithms: RSA 4096bits, AES, SHA1/SHA224/SHA256/SHA384/SHA512, 3DES(ECB,CBC), KOREAN SEED, ECC FP 160 bits to 521 bits

## Storage and Memory

The P71 has a few hundreds kilobytes of ROM (read-only) memory. The contents of the ROM, as well as its layout is specified by the **ROM mask**. This ROM mask is applied by the card factory, according to the customers order. This process requires **fabrication keys** by NXP (or even a custom silicon die), which are highly protected and usually only provided to contracted partners and factories.

The P71 J3R200 has about `200 KB` of EEPROM (re-writeable) nonvolatile flash memory. According to our manufacturer, the flexSecure has at least `164 KB` of EEPROM available. The Mifare classic emulation applet was removed from the ROM mask, otherwise only about `99 KB` flash would have been available.

Measurements show an available persistent (EEPROM) storage of at least `167736` bytes for the flexSecure.

The ROM is typically used for storing pre-deployed packages which will never change. The EEPROM then stores only the applet instances, as well as configuration data like e.g. secret keys. In our case, all packages are loaded during runtime into the EEPROM, and the ROM is pretty much unused expect for some cryptographic algorithms and the operating system. 

The P71 J3R200 has about `8 KB` of volatile RAM available. Some of that is used by the operating system and cryptographic algorithms. According to our manufacturer, at least `4 KB` of RAM is available for applets on the flexSecure.

Measurements show a transient (RAM) storage size of at least `4115` / `4112` (reset / deselect) bytes for the flexSecure.

The Apex Flex uses either the `J3R200` or the `J3R180` chip, which one is unclear at the time of writing. They have the same base specs (besides the `J3R180` having a `20 KB` smaller EEPROM), and use a different ROM mask specified by Fidesmo. The ROM mask should contain the pre-loaded payment package, and the EEPROM additionally contains the instance of this payment applet. This takes quite a chunk of memory (allegedly about `100 KB`). Information on these Fidesmo-deployed chips is scarce, maybe the payment package is stored in the EEPROM as well. In any case, the remaining amount of storage and memory is significantly smaller than on the flexSecure.

Measurements show an available persistent (EEPROM) storage of at least `84336` bytes, and a transient (RAM) storage size of at least `4054` / `4160` (reset / deselect) bytes for the Apex Flex.

## Important Note concerning Lockout

The P71 includes a hardware functionality which physically bricks the chip after too many authentication failures, when using the wrong GlobalPlatform key. There is no way to recover the chip after that, it permanently turns into dead silicon. If you change your GlobalPlatformKey, be sure to made a backup of the key. Also make extra sure to always specify the correct key when using GlobalPlatformPro. By default (if no key is specified), the default test key (see above) is used. Also, do not remove the management applet package (`A0000001515350`), or security controller (`A000000151000000`). They are part of the operating system.

It is important to note, if you have an Apex Flex then you do not have the master key and you cannot change it. You can brick your Apex Flex by attempting to use GlobalPlatformPro to access it without the key. Do not attempt to access your Apex Flex using GPP or you will end up bricking it.

## Apex Flex & Fidesmo AB

The Apex Flex uses a chip personalized by Fidesmo AB, a swedish company providing a set of services and APIs for managing, deploying, and communicating with smartcard applets across many devices. They provide a mobile app-store, which can be used to load new applets onto your smartcard. They also provide payment functionality on their cards, as well as backend connections to service providers.

### Ecosystem Constraints

Loading a third-party applet onto a Fidesmo-deployed smartcard requires the applet to be signed by Fidesmo, as they keep the administrative keys to the cards private. This signing process requires a developer account and an internet connection to the Fidesmo signing servers. The signature ensures that third-party applets are only allowed to be deployed into the "low-security" domain, i.e. not the one where the payment code runs.

Fidesmo retains the right to refuse to sign any applet they do not want running on their card. In addition, they only allow AIDs starting with their registered AID, joined with your developer ID. This ensures that your AIDs don't collide with any others. In special cases, you might be able to reach an agreement with them to use a different AID.

The Fidesmo `fdsm` tool handles the signing process, and is able to interface GP to load and manage applets onto a card. GPP can only be used in a very limited amount, as the administrative key is kept by Fidesmo. On an empty card with administrative access, signatures are not enforced - unless you specifically configure a security domain and sign the applets using your own certificates.

### Applet Availability

It should be said that Fidesmo provides a very valuable service, and that their partnership with VivoKey on the Apex Flex is a big win for everyone. For example, Fidesmo provides the mentioned mobile app store, which provides an easy way to discover and install applets onto the Apex Flex. 

Typically companies will deploy their applets to a smart card and lock he chip down, creating a single application card (like payment cards, access badges, Tesla key cards, etc). Fidesmo brokers on-chip security in a way that makes it possible for 3rd parties to feel comfortable enough to allow their applets to be deployed and operate on-chip with other applets. More specifically, Fidesmo's management of the master key, review of applets before publication, and deployment of applets into separate security domains on-chip, does not allow end users the means to access or attempt to subvert or maliciously attack the applet code or data stored in memory. Without this arrangement, it would not be possible to deploy trusted applications from 3rd parties (like payment applets) in a multi-application environment.

The flexSecure uses an empty chip with administrative keys available, which has not been personalized by Fidesmo. Consequently, it can not interact with the Fidesmo services and app store. You have to source the packages you want to install by yourself somewhere on the internet, or to compile them from source. You also have to load them onto the card manually, everything has to be managed using GP / GPP, but any AID you want can be deployed in order to impersonate other tokens or cards.

## Payments

It is unclear if and when the payment functionality of the Apex Flex will ever be active. Mastercard / Visa have some ideological issues supporting implants, so although the Fidesmo payment applet works great, it is unable to be tokenized (configured with payment account data) on the Apex Flex. The payment applet will be loaded on the chip, but won't be possible to use. The applet will lie dormant until Visa / Mastercard sort out their issues.

The flexSecure comes without a payment applet. Although there are payment applet implementations by Fidesmo and e.g. Mastercard available, the legal paperwork and security requirements (sectioned chips, private administrative keys) mean that the flexSecure cannot and will not be able to make payments.

## Sources and Further Reading

- https://www.nxp.com/products/security-and-authentication/security-controllers/smartmx3-p71d321-secure-and-flexible-microcontroller:SMARTMX3-P71D321
- https://www.javacardos.com/store/products/11020
- https://fidesmo.com/
- https://github.com/fidesmo/fdsm
- https://github.com/DangerousThings/javacard-memory

Improve this document: https://github.com/DangerousThings/flexSecure-applets/tree/master/docs
