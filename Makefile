VERSION = 0
PATCHLEVEL = 0
SUBLEVEL = 1

ARCH = mips
CROSS_COMPILE = mipsel-linux-
#CROSS_COMPILE = 

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

MINIBIOSINCLUDE = -I $(src)/include

# Files to ingore in find statement
FIND_IGNORE = \( -name .svn -o -name .git \) -prune -o

export src obj
export MINIBIOSVERSION
include util/Makefile


rom: $(src)/
	@echo "not imp now"
ram:
	@echo "not imp now"

prepare:
	@rm -rf $(obj)
	@mkdir -p $(obj)

clean: 
	rm -rf $(obj)
	rm -rf $(src)/include/autoconf.h
	@find . $(FIND_IGNORE) \
			\( -name '*.o' -o -name '*.tmp' \) \
			-type f -print |xargs rm -f
