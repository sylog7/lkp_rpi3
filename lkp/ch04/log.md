# 실행 결과

~~~sh
pi@raspberrypi:~/ldd$ sudo insmod printk_loglvl.ko                                                                          
[  388.840160] Hello, world @ log-level KERN_EMERG   [0]
[  388.845334] Hello, world @ log-level KERN_ALERT   [1]
[  388.850475] Hello, world @ log-level KERN_CRIT    [2]

~~~

~~~sh
pi@raspberrypi:~/ldd$ sudo insmod helloworld_lkm.ko
[   63.644074] helloworld_lkm: loading out-of-tree module taints kernel.
[   63.644588] Hello, world
[  110.975123] Hello, world @ log-level KERN_EMERG   [0]
[  110.980349] Hello, world @ log-level KERN_ALERT   [1]
[  110.985549] Hello, world @ log-level KERN_CRIT    [2]
[  110.990691] Hello, world @ log-level KERN_ERR     [3]
[  110.990697] Hello, world @ log-level KERN_WARNING [4]
[  110.990702] Hello, world @ log-level KERN_NOTICE  [5]
[  110.990707] Hello, world @ log-level KERN_INFO    [6]
~~~

~~~sh
pi@raspberrypi:~/ldd$ sudo rmmod helloworld_lkm 
pi@raspberrypi:~/ldd$ sudo rmmod printk_loglvl 
[  498.990750] Goodbye, world! Climate change has done us in...
[  506.327719] Goodby, world @ log-level KERN_INFO    [6]
~~~