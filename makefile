AS	= tasm
ASFLAGS	= /Ml /z /t
LD	= tlink
LDFLAGS	= /x/c/t
RM	= del

all:	bootelks.com  getints.bin

bootelks.com:	bootelks.obj
	$(LD) $(LDFLAGS) bootelks.obj, bootelks.com,,

bootelks.obj:	bootelks.asm Makefile
	$(AS) $(ASFLAGS) bootelks.asm;

getints.bin: getints.obj
	$(LD) $(LDFLAGS) getints.obj, getints.bin,,

getints.obj:	getints.asm Makefile
	$(AS) $(ASFLAGS) getints.asm;
zip:
	pkzip -u -ex -xbootelks.zip bootelks.zip

clean:
	$(RM) bootelks.obj
	$(RM) getints.obj