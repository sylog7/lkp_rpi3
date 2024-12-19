# procmap

https://github.com/kaiwan/procmap


## download, env setup
### download
~~~bash
git clone https://github.com/kaiwan/procmap
~~~

### build(x86)
~~~bash
cd procmap
vim procmap_kernel
~~~
  
modify below line like this.  
Change CC variable's value(gcc) to gcc-12
~~~bash
# Compiler
 CC     := $(CROSS_COMPILE)gcc-12
 #CC    := clang
 STRIP := ${CROSS_COMPILE}strip
 
 PWD            := $(shell pwd)
 obj-m          += ${FNAME_C}.o

~~~
  
Here's author's tip about error.
~~~bash
     @echo '--- Tips ---'
     @echo '  If the build fails with a (GCC compiler failure) message like'
     @echo '   unrecognized command-line option ‘-ftrivial-auto-var-init=zero’'
     @echo '  it's likely that you're using an older GCC. Try installing gcc-12 (or later),'
     @echo '  change this Makefile CC variable to "gcc-12" (or whatever) and retry'
~~~

### package install in target(x86 desktop)
~~~bash
sudo apt-get install smem
sudo apt-get install yad
~~~

### run procmap(x86 desktop)
~~~bash
cd procmap_kernel
make
sudo insmod procmap.ko
cd -
./procmap
~~~


### build(arm64)
~~~bash
cd procmap
vim procmap_kernel
~~~

My build.sh will set environment variables(KERNEL_DIR, CROSS_COMPILE)
Change KDIR of arm64 target to KERNEL_DIR environment variable.  
CC variable doesn't neet to modify.
~~~bash
ifeq ($(ARCH),arm)
  # *UPDATE* 'KDIR' below to point to the ARM Linux kernel source tree on your box
  KDIR ?= ~/arm_prj/kernel/linux
else ifeq ($(ARCH),arm64)
  # *UPDATE* 'KDIR' below to point to the ARM64 (AArch64) Linux kernel source
  # tree on your box
  #KDIR ?= ~/arm64_prj/kernel/linux
  KDIR ?= ${KERNEL_DIR}
else ifeq ($(ARCH),powerpc)
  # *UPDATE* 'KDIR' below to point to the PPC64 Linux kernel source tree on your box
  KDIR ?= ~/ppc_prj/kernel/linux-5.4
else
  # 'KDIR' is the Linux 'kernel headers' package on your host system; this is
  # usually an x86_64, but could be anything, really (f.e. building directly
  # on a Raspberry Pi implies that it's the host)
  KDIR ?= /lib/modules/$(shell uname -r)/build
endif
~~~

### package install in target(arm64)
~~~bash
sudo apt-get install smem
sudo apt-get install yad
~~~

### run procmap(arm64)
~~~bash
cd procmap_kernel
make
sudo insmod procmap.ko
cd -
./procmap
~~~

