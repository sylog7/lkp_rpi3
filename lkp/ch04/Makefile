PWD		:= $(shell pwd)
KDIR	:= ../../linux/
obj-m	+= printk_loglvl.o

# Enable the pr_debug() and pr_devel() as well by removing the comment from
# one of the lines below
# (Note: EXTRA_CFLAGS deprecated; use ccflags-y)
#ccflags-y += -DDEBUG
#CFLAGS_printk_loglvl.o := -DDEBUG

all:
	make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -C $(KDIR) M=$(PWD) modules
install:
	make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -C $(KDIR) M=$(PWD) modules_install
clean:
	make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -C $(KDIR) M=$(PWD) clean
