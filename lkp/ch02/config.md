
# configure kernel and build kernel.
Kernel에서 제공하는 많은 기능들이 있는데, 이것들은 KBuild 시스템을 통해서 빌드된다.  
KBuild 시스템 사용법에 맞게 CONFIG를 직접 추가할수도 있고,  
기존의 CONFIG들 중 필요한 것만 남겨놓고 필요없는 것을 제거할 수도 있다.  
반대로 커널에서 제공하는 기능을 빌드하고 싶을 경우, enable할수도 있다.  
CONFIG_HZ처럼 CONFIG값을 수정할 수도 있다.  

책에서는 데스크톱 기반의 커널 빌드를 주로 실습하지만,  
여기서는 최대한 raspberry pi환경에서 실습해볼 것이다.  
raspberry pi 3, 4 버전 모두 동일하게 사용이 가능하다.  

## kernel configuration
 - CONFIG_IKCONFIG: “Kernel .config support” option
 - CONFIG_IKCONFIG_PROC:“Enable access to .config through /proc/config.gz” option
 - CONFIG_LOCALVERSION: The string to append to the kernel version. Take uname –r as an example
 - CONFIG_HZ: Add feature for checking whether kernel config is applied. 
            We will show What this feature means in Chapter 10.

~~~bash
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
~~~

## build
여기서는 raspberry pi용 kernel을 빌드, 설치를 할 것이므로,  
raspberry pi 공식 문서의 내용을 참고해서 build, install script를 별도로 구현했다.  
공식 문서 url은 아래와 같다.  
[raspi kernel official document](https://www.raspberrypi.com/documentation/computers/linux_kernel.html)
구현된 build script경로는 아래와 같다.  
[build script](../../build.sh)

구현된 내용만 따로 발췌해왔다.  

~~~bash
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
   # sudo mount /dev/sda1 ${BOOT_DIR}
   # sudo mount /dev/sda2 ${ROOTFS_DIR}
    sudo mount /dev/sdc1 ${BOOT_DIR}
    sudo mount /dev/sdc2 ${ROOTFS_DIR}
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
        INSTALL_MOD_PATH=${ROOTFS_DIR} modules_install
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
~~~

