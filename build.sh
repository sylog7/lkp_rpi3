#!/bin/bash

set_env()
{
    # global variable
    export TOP_DIR=`pwd`

    # variables for compile kernel
    export ARCH=arm64
    # export CROSS_COMPILE=arm-linux-gnueabihf-
    export CROSS_COMPILE=aarch64-linux-gnu-
    # export KERNEL=kernel7
    export KERNEL=kernel8

    # variables for mount and install module and kernel.
    export KERNEL_DIR=$TOP_DIR/linux
    export BOOT_DIR=$TOP_DIR/mnt/boot
    export ROOTFS_DIR=$TOP_DIR/mnt/root
}

get_kernel()
{
    if [ -d linux ]; then
        echo "alrady here raspberry pi kernel ..."
    else
        echo "get kernel ..."
        # git clone --depth=1 --branch rpi-6.6.y https://github.com/raspberrypi/linux
        git clone --depth=1 --branch rpi-6.1.y https://github.com/raspberrypi/linux
    fi

    cd linux
#    export LINUX_DIR=`pwd`
}

configure_kernel()
{
    echo "configure kernel ..."
    # export KERNEL=kernel7
    export KERNEL=kernel8
#    make bcm2709_defconfig
    # make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- bcm2709_defconfig
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} bcm2711_defconfig

    # CONFIG_IKCONFIG for the “Kernel .config support” option
    scripts/config --enable CONFIG_IKCONFIG
    # CONFIG IKCONFIG_PROC for the “Enable access to .config through /proc/config.gz” option
    scripts/config --enable CONFIG_IKCONFIG_PROC

    # the string to append to the kernel version. Take uname –r as an example
    # --set-str option string: Set option to "string"
    scripts/config --set-str CONFIG_LOCALVERSION "-lkp-kernel"

    # the frequency at which the timer (hardware) interrupt is triggered.
    # Timer frequency. You’ll learn the details regarding this tunable in Chapter 10, The CPU Sched-uler – Part 1:
	# --set-val option value: Set option to value
    scripts/config --disable CONFIG_HZ_250
    scripts/config --enable CONFIG_HZ_300
    scripts/config --set-val CONFIG_HZ 300
}

build_kernel()
{
    # make -j$(nproc) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage modules dtbs
    make -j$(nproc) ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} Image modules dtbs
}

mount_dirs()
{
    echo "======= mount_dirs() ========"
    if [ -d $TOP_DIR/mnt ]; then
        echo "mount dir already here"
    else
        echo "create dirs for mount.."
        mkdir -p ${BOOT_DIR}
        mkdir -p ${ROOTFS_DIR}
    fi

    echo "mount dirs for boot, rootfs..."
    sudo mount /dev/sda1 ${BOOT_DIR}
    sudo mount /dev/sda2 ${ROOTFS_DIR}
}

install_modules()
{
    echo "======= install_modules() ========="
    cd $KERNEL_DIR
    # sudo env PATH=$PATH make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- \
    #     INSTALL_MOD_PATH=$TOP_DIR/mnt/ext4 modules_install
    #sudo env PATH=$PATH make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} \
    #    INSTALL_MOD_PATH=$TOP_DIR/${ROOTFS_DIR} modules_install
    sudo env PATH=$PATH make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} \
        INSTALL_MOD_PATH=mnt/root modules_install
}


# https://www.raspberrypi.com/documentation/computers/linux_kernel.html
install_kernel()
{
    echo "======= install_kernel() =========="
    cd $KERNEL_DIR
    sudo cp -vf $BOOT_DIR/$KERNEL.img $BOOT_DIR/$KERNEL-backup.img
    # sudo cp arch/${ARCH}/boot/zImage $BOOD_DIR/$KERNEL.img
    sudo cp -vf arch/${ARCH}/boot/Image ${BOOT_DIR}/$KERNEL.img
    sudo cp -vf arch/${ARCH}/boot/dts/broadcom/*.dtb ${BOOT_DIR}/
    sudo cp -vf arch/${ARCH}/boot/dts/overlays/*.dtb* ${BOOT_DIR}/overlays/
    sudo cp -vf arch/${ARCH}/boot/dts/overlays/README ${BOOT_DIR}/overlays/
    sudo umount $BOOT_DIR
    sudo umount $ROOTFS_DIR

    cd $TOP_DIR
}

export TOP_DIR=`pwd`
set_env

get_kernel

configure_kernel

build_kernel

mount_dirs

install_modules

install_kernel


