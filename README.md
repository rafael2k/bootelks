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

