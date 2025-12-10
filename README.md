# BootELKS

Downloaded from: https://archive.org/details/bootelks

This is version 0.1 of BootELKS, the dos boot loader for ELKS.

The programm is very basic at the moment. There aren't any command
line parameters or anything.
It expects to have a kernel image with the name IMAGE in the current
directory.
In addition to that, we need and image of the first 500h bytes of the
memory before any OS is loaded. The file GETINTS.BIN is a boot sector
which writes these 500h bytes into the first 3 sectors of the disk
it is started from.
This image has to be named INTS.BIN and copied into the same directory
as the IMAGE file.
BootELKS doesn't work under DOSEMU at the moment.

INSTALLATION

1. Copy GETINTS.BIN to an empty disk using LINUX command dd.

        dd if=getints.bin of=/dev/fd0 bs=512 count=1

2. Shutdown computer and reboot with disk to start getints.bin

3. Copy generated image from disk usint LINUX comand dd and name it
   INTS.BIN. The whole thing has the size of 3 sectors!!

        dd if=/dev/fd0 of=ints.bin bs=512 count=3

4. Copy BOOTELKS.COM, INTS.BIN and the kernel image (with the name IMAGE)
   into one directory.

TODO-List:
- Command line parser for flexible loading of the images etc.
- Check if INTS.BIN is valid by comparing BIOS dates.
- Improve error handling if one of the images is not present etc.
- Tool to write GETINTS.BIN and read INTS.BIN using DOS.

  ---

Instructions from @toncho11 from https://github.com/ghaerr/elks/issues/2236

  BOOTELKS - Boot ELKS from DOS

This setup allows you to load the ELKS kernel from a DOS environment using BOOTELKS.COM.
REQUIRED FILES

    BOOTELKS.COM
        The DOS program that loads and starts the ELKS kernel.

    IMAGE
        The ELKS kernel image file. The ELKS' kernel is called "kernel" and must be renamed to "image".
        Must be the raw kernel binary, not a floppy or disk image.
        Can be compiled from ELKS source or obtained prebuilt.

    INTS.BIN
        A binary dump of the system's Interrupt Vector Table (IVT) and BIOS data.
        Must be exactly 0x500 (1280) bytes, copied from RAM starting at segment 0x0000.
        Created using the GETINTS utility described below.

    GETINTS.COM

        A small DOS program to dump the first 0x500 bytes of memory.

        Run it under a clean DOS environment to generate INTS.BIN.

        Example usage:

            GETINTS > INTS.BIN

SETUP INSTRUCTIONS

    Boot into a clean DOS environment (MS-DOS or FreeDOS). Avoid loading memory managers or TSRs.

    Place the following files in the same directory:
        BOOTELKS.COM
        IMAGE
        INTS.BIN

    Example directory layout:

    A:\ELKS
    ├── BOOTELKS.COM
    ├── IMAGE
    └── INTS.BIN

    Run BOOTELKS:

        BOOTELKS

    This will:
        Load the IMAGE (ELKS kernel) into memory.
        Restore BIOS state from INTS.BIN.
        Transfer execution to ELKS.

NOTES

    You must create INTS.BIN only once per machine (or BIOS environment).
    BOOTELKS is not compatible with compressed kernel images.

TROUBLESHOOTING

    If BOOTELKS hangs or resets, ensure:
        The IMAGE is a raw, valid ELKS kernel.
        INTS.BIN is correct and generated in a clean DOS state.
        No drivers or memory managers (like HIMEM.SYS or EMM386) are loaded.


