VERSION = 0
PATCHLEVEL = 0
SUBLEVEL = 2

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

MINIBIOSINCLUDE = $(src)/include  -I $(src)/board/loongson2f-yeeloong-8089/include

# Files to ingore in find statement
FIND_IGNORE = \( -name .svn -o -name .git \) -prune -o

head-y = $(src)/init/start

minibios-head = $(head-y)
minibios-main = $(core-y) $(libs-y) $(drivers-y)
minibios-lds  = $(src)/board/loongson2f-yeeloong-8089/ld.script

export src obj
export MINIBIOSVERSION
all:	minibios Makefile
include util/Makefile
include init/Makefile


PHONY += all
minibios: $(minibios-lds) $(minibios-head) $(minibios-main)

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
	rm -rf $(src)/init/hello.o
	rm -rf $(src)/init/start.s
	rm -rf $(src)/init/start
	rm -rf $(src)/minibios
	rm -rf $(src)/minibios.rom
PHONY += help 
help:
	@echo  "make menuconfig"
	@echo  "make rom"
	@echo  "           get minibios.bin as result"
.PHONY : $(PHONY)

