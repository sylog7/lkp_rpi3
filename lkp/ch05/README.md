# Writing First Kernel Module - Part 2

## Makefile template
기본 Makefile에 비해 더 향상된 Makefile tamplate을 소개해준다.  
code-style이나 static analysis, dynamic analysis는 프로젝트에 적용하면 좋을 듯하다.   
~~~bash
$ make help
=== Makefile Help : additional targets available ===

TIP: Type make <tab><tab> to show all valid targets
FYI: KDIR=/lib/modules/6.5.6-200.fc38.x86_64/build ARCH= CROSS_COMPILE= ccflags-y="-UDEBUG -DDYNAMIC_DEBUG_MODULE" MYDEBUG=n DBG_STRIP=n

--- usual kernel LKM targets ---
typing "make" or "all" target : builds the kernel module object (the .ko)
install     : installs the kernel module(s) to INSTALL_MOD_PATH (default here: /lib/modules/6.5.6-200.fc38.x86_64/).
            : Takes care of performing debug-only symbols stripping iff MYDEBUG=n and not using module signature
nsdeps      : namespace dependencies resolution; for possibly importing namespaces
clean       : cleanup - remove all kernel objects, temp files/dirs, etc

--- kernel code style targets ---
code-style : "wrapper" target over the following kernel code style targets
 indent     : run the indent utility on source file(s) to indent them as per the kernel code style
 checkpatch : run the kernel code style checker tool on source file(s)

--- kernel static analyzer targets ---
sa         : "wrapper" target over the following kernel static analyzer targets
 sa_sparse     : run the static analysis sparse tool on the source file(s)
 sa_gcc        : run gcc with option -W1 ("Generally useful warnings") on the source file(s)
 sa_flawfinder : run the static analysis flawfinder tool on the source file(s)
 sa_cppcheck   : run the static analysis cppcheck tool on the source file(s)
TIP: use Coccinelle as well: https://www.kernel.org/doc/html/v6.1/dev-tools/coccinelle.html

--- kernel dynamic analysis targets ---
da_kasan   : DUMMY target: this is to remind you to run your code with the dynamic analysis KASAN tool enabled; requires configuring the kernel with CONFIG_KASAN On, rebuild and boot it
da_lockdep : DUMMY target: this is to remind you to run your code with the dynamic analysis LOCKDEP tool (for deep locking issues analysis) enabled; requires configuring the kernel with CONFIG_PROVE_LOCKING On, rebuild and boot it
TIP: Best to build a debug kernel with several kernel debug config options turned On, boot via it and run all your test cases

--- misc targets ---
tarxz-pkg  : tar and compress the LKM source files as a tar.xz into the dir above; allows one to transfer and build the module on another system
        TIP: When extracting, to extract into a directory with the same name as the tar file, do this:
              tar -xvf lkm_template.tar.xz --one-top-level
help       : this help target
$ 
~~~


## cross
책을 보면, cross compile용 설정에 관해 나와있다.  
저작권 때문에 자세한 내용은 쓸 수 없다.(책을 직접 보는 것이 더 좋다.)  
그냥 당연하게 써왔던 것들이지만 설명이 잘 되어 있다.  
~~~bash
pi@raspberrypi:~/ldd$ sudo insmod lkm_template.ko 
pi@raspberrypi:~/ldd$ sudo dmesg | tail
...
[   36.166458] lkm_template: loading out-of-tree module taints kernel.
[   36.166966] lkm_template:lkm_template_init(): inserted
pi@raspberrypi:~/ldd$ 
pi@raspberrypi:~/ldd$ sudo rmmod lkm_template 
pi@raspberrypi:~/ldd$ sudo dmesg |tail
...
[   36.166458] lkm_template: loading out-of-tree module taints kernel.
[   36.166966] lkm_template:lkm_template_init(): inserted
[   52.160196] lkm_template:lkm_template_exit(): removed
pi@raspberrypi:~/ldd$
~~~
TODO: out-of-tree module taints kernel로그가 출력된다.  
Makefile에서 build할 때, INSTALL_MOD_PATH를 넘기도록 수정해보자.  


## fp(floating point) in lkm
커널에서는 floating point(부동소수점) 연산이 지원되지 않는다.  
예전에 카메라 디바이스 드라이버를 개발하면서 비슷한 시도를 했던 경험이 있다.  
결국엔 부동소수점 연산하는 부분을 user space application으로 옮겼었다.
부동소수점 연산을 위해서는 별도의 함수를 사용하면 가능하긴 하다.  
kernel_fpu_begin() 이후에 부동소수점 연산을 하고  
연산이 끝난 후에는 kernel_fpu_end()로 닫아주면 된다.  
  
