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

HOSTCC		= cc
HOSTCXX		= g++
HOSTCFLAGS	= -Wall -Wstrict-prototypes -O2 -fomit-frame-pointer
HOSTCXXFLAGS= - O2

src = $(shell pwd)
obj = $(shell pwd)/build
MINIBIOSVERSION = $(VERSION).$(PATCHLEVEL).$(SUBLEVEL)

export src obj
export MINIBIOSVERSION
include util/Makefile


rom:
	echo $(MINIBIOSVERSION)
	@echo "not imp now"
ram:

prepare:
	@rm -rf $(obj)
	@mkdir -p $(obj)

clean:
	rm -rf $(obj)
