# ch4/helloworld_lkm/Makefile
# Simplest kernel module Makefile

PWD   := $(shell pwd)
# KDIR  := /lib/modules/$(shell uname -r)/build/
KDIR	:= ../../../linux/
obj-m += helloworld_lkm.o

all:
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} -C $(KDIR) M=$(PWD) modules
install:
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} -C $(KDIR) M=$(PWD) modules_install
clean:
	make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} -C $(KDIR) M=$(PWD) clean
