# 실행 결과

module들을 insmod해본다.  
printk_loglvl.ko를 insmod하면 콘솔 출력으로 KERN_CRIT(2)~KERN_EMERG(1)까지의 로그레벨은 출력된다.  
로그 레벨이 높을 수록 위험도? 또는 우선순위가 낮음을 의미할 것이다..  
만약 KERN_ERR까지 default로 콘솔에 출력하게 하려면.. KERNEL CONFIG를 수정해주면 되지 않을까..  
굳이 바꿔줄 필요는 못느낀다.  
~~~sh
pi@raspberrypi:~/ldd$ sudo inmod helloworld_lkm.ko
pi@raspberrypi:~/ldd$ sudo insmod printk_loglvl.ko 
[  350.344664] Hello, world @ log-level KERN_EMERG   [0]
[  350.349876] Hello, world @ log-level KERN_ALERT   [1]
[  350.355041] Hello, world @ log-level KERN_CRIT    [2]
~~~
  
dmesg로 로그를 출력해본다. 모두 출력된다. KERN_EMERG(0)~KERN_INFO(6)까지의 로그가 출력된다.  
~~~bash
pi@raspberrypi:~/ldd$ sudo dmesg | tail -n 30
...
[  300.158700] helloworld_lkm: loading out-of-tree module taints kernel.
[  300.159111] Hello, world
[  302.557010] hwmon hwmon1: Undervoltage detected!
[  306.823677] hwmon hwmon1: Voltage normalised
[  350.344664] Hello, world @ log-level KERN_EMERG   [0]
[  350.349876] Hello, world @ log-level KERN_ALERT   [1]
[  350.355041] Hello, world @ log-level KERN_CRIT    [2]
[  350.360215] Hello, world @ log-level KERN_ERR     [3]
[  350.360224] Hello, world @ log-level KERN_WARNING [4]
[  350.360230] Hello, world @ log-level KERN_NOTICE  [5]
[  350.360235] Hello, world @ log-level KERN_INFO    [6]
~~~

'ccflags-y += -DDEBUG'구문을 추가한 뒤에 빌드해보자.  
pr_debug(), pr_devel()함수로 출력한 로그가 출력되고  
loglevel KERN_DEBUG(7)로 확인된다.  
develop, debug버전에서만 필요한 로그들은 pr_debug(), pr_devel()을 사용하면 유용할 것이다.  
product 버전에서는 'ccflags-y += -DDEBUG'구문을 주석처리한 뒤에 배포하면 된다.  
~~~bash
pi@raspberrypi:~/ldd$ sudo dmesg |tail -n 30
...
[   49.234875] helloworld_lkm: loading out-of-tree module taints kernel.
[   49.235320] Hello, world
[   55.181749] Hello, world @ log-level KERN_EMERG   [0]
[   55.186971] Hello, world @ log-level KERN_ALERT   [1]
[   55.192126] Hello, world @ log-level KERN_CRIT    [2]
[   55.197268] Hello, world @ log-level KERN_ERR     [3]
[   55.197274] Hello, world @ log-level KERN_WARNING [4]
[   55.197280] Hello, world @ log-level KERN_NOTICE  [5]
[   55.197285] Hello, world @ log-level KERN_INFO    [6]
[   55.197291] Hello, world @ log-level KERN_DEBUG   [7]
[   55.197300] Hello, world via the pr_devel() macro (eff @KERN_DEBUG) [7]
pi@raspberrypi:~/ldd$ 

~~~


모듈을 제거해보자.  
~~~sh
pi@raspberrypi:~/ldd$ sudo rmmod helloworld_lkm 
pi@raspberrypi:~/ldd$ sudo rmmod printk_loglvl 
[  498.990750] Goodbye, world! Climate change has done us in...
[  506.327719] Goodby, world @ log-level KERN_INFO    [6]
~~~
