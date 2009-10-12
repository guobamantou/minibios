VERSION = 0
PATCHLEVEL = 0
SUBLEVEL = 6

ARCH = mips
CROSS_COMPILE = mipsel-linux-gnu-

AR	= $(CROSS_COMPILE)ar
AS	= $(CROSS_COMPILE)as
CC	= $(CROSS_COMPILE)gcc
CPP	= $(CC) -E
LD	= $(CROSS_COMPILE)ld
LN	= $(CROSS_COMPILE)ln
OBJCOPY = $(CROSS_COMPILE)objcopy
CFLAGS = -Os -Wall -Wstrict-prototypes -Wno-trigraphs \
		-Werror-implicit-function-declaration -Wstrict-aliasing \
		-fno-common -ffreestanding -fno-builtin \
		-mpreferred-stack-boundary=2 -pipe

HOSTCC		= cc
HOSTCXX		= g++
HOSTCFLAGS	= -Wall -Wstrict-prototypes -O2 -fomit-frame-pointer
HOSTCXXFLAGS= - O2

src = $(shell pwd)
obj = $(shell pwd)/build
MINIBIOSVERSION = $(VERSION).$(PATCHLEVEL).$(SUBLEVEL)

MINIBIOSINCLUDE = $(src)/include  -I board/loongson2f-yeeloong-8089/include

# Files to ingore in find statement
FIND_IGNORE = \( -name .svn -o -name .git \) -prune -o

minibios-head = $(head-y)
minibios-main = $(core-y) $(libs-y) $(drivers-y)
minibios-lds  = board/loongson2f-yeeloong-8089/ld.script

export src obj
export MINIBIOSVERSION
export head-y drivers-y libs-y
all:	minibios Makefile
include util/Makefile
include init/Makefile
include lib/Makefile
include cpu/loongson2f/Makefile
include drivers/Makefile


PHONY += all
minibios:  $(minibios-head) $(minibios-main)
	$(LD) $^ -o minibios -e _start -T $(minibios-lds)
	$(OBJCOPY) -O binary minibios minibios.rom 
	cp minibios.rom /tftpboot
	cp minibios /tftpboot
	@du -sb minibios.rom
PHONY += ctags
ctags: clean
	ctags -R
PHONY += prepare
prepare:
	@rm -rf $(obj)
	@mkdir -p $(obj)
PHONY += clean
cleanconfig:
	rm -rf $(src)/include/autoconf.h
	rm -rf $(src)/.config
clean: 
	rm -rf $(obj)
	@find . $(FIND_IGNORE) \
			\( -name '*.o' -o -name '*.tmp' \) \
			-type f -print |xargs rm -f
	rm -rf $(src)/init/start.o
	rm -rf $(src)/init/start.s
	rm -rf $(src)/minibios
	rm -rf $(src)/minibios.rom
	rm -rf /tftpboot/minibios.rom
	rm -rf /tftpboot/minibios
PHONY += help 
help:
	@echo  "make "
	@echo  "make menuconfig"
	@echo  "make clean"
	@echo  "make cleanconfig"
	@echo  "make bak"
	@echo  "make ctags"
bak:
	tar czf /tmp/minibios.tar.gz .
	cp /tmp/minibios.tar.gz /mnt/sda5/
	scp /mnt/sda5/minibios.tar.gz software@172.16.0.30:xiangy
.PHONY : $(PHONY)

