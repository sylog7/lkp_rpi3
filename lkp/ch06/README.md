# Kernel_Internals_Essentials_Process_And_Threads

## 실습1 running countem.sh script
현재 활성 상태인 프로세스와 스레드의 수를 세는 간단한 Bash 스크립트(ch6/countem.sh)를 실행해보자.  
Raspberry pi Zero 2W, Raspbian에서 이 작업을 했고 결과는 아래 출력을 살펴보자.  
~~~bash
pi@raspberrypi:~/LKP_2E/ch6$ ./countem.sh
System release info:
No LSB modules are available.
Distributor ID: Debian
Description:    Debian GNU/Linux 12 (bookworm)
Release:        12
Codename:       bookworm
Debian GNU/Linux 12 \n \l

PRETTY_NAME="Debian GNU/Linux 12 (bookworm)"
NAME="Debian GNU/Linux"
VERSION_ID="12"
VERSION="12 (bookworm)"
VERSION_CODENAME=bookworm
ID=debian
HOME_URL="https://www.debian.org/"
SUPPORT_URL="https://www.debian.org/support"
BUG_REPORT_URL="https://bugs.debian.org/"

Total # of processes alive               =       201
Total # of threads alive                 =       293
Total # of kernel threads alive          =       134
Thus, total # of user mode threads alive =       159
pi@raspberrypi:~/LKP_2E/ch6$
pi@raspberrypi:~/LKP_2E/ch6$
~~~
스크립트는 ps를 이용해서 프로세스와 스레드의 수를 얻고 있다.
 - 모든 프로세스 출력(total_prcs): ps -A 
 - 모든 스레드 출력(total_thrds): ps -LA
 - 모든 커널 스레드 출력(total_kthrds): ps aux
~~~bash
total_prcs=$(ps -A|wc -l)
printf "\nTotal # of processes alive               = %9d\n" ${total_prcs}

# ps -LA shows all threads
total_thrds=$(ps -LA|wc -l)
printf "Total # of threads alive                 = %9d\n" ${total_thrds}

# ps aux shows all kernel threads names (col 11) in square brackets; count 'em
total_kthrds=$(ps aux|awk '{print $11}'|grep "^\["|wc -l)

printf "Total # of kernel threads alive          = %9d\n" ${total_kthrds}
printf "Thus, total # of user mode threads alive = %9d\n" $((${total_thrds}-${total_kthrds}))
~~~

### Summarizing the kernel with respect to threads, task structures, and stacks
countem.sh 스크립트의 샘플 실행에서 얻은 학습과 결과를 요약해보자.  
#### 작업 구조(Task structures):
    • 모든 활성 스레드(사용자 또는 커널)는 커널에 해당 작업 구조(struct task_struct)를 가지고 있다. 이것이 커널이 스레드를 추적하고 관리하는 방식이다.
    • ch6/countem.sh 스크립트:
        • 시스템에 활성 스레드(사용자 및 커널 모두)가 총 293개이므로 커널 메모리에 총 293개의 task_struct(메타데이터)가 있음을 의미한다.(코드에서는 struct task_struct). 다음과 같이 말할 수 있다.
        • 이러한 task struct 중 159개는 사용자 스레드를 나타낸다.
        • 나머지(293 - 159 =) 134개의 task struct는 커널 스레드의 task struct를 나타낸다.  
#### 스택:
	• 모든 사용자 공간 스레드에는 두 개의 스택이 있다.
		• 사용자 모드 스택(스레드가 사용자 모드 코드 경로를 실행할 때 실행됨)
		• 커널 모드 스택(스레드가 커널 모드 코드 경로를 실행할 때 실행됨)
		• 또한 하드웨어 인터럽트 핸들러가 코드 경로를 실행할 때 사용할 별도의 코어당 IRQ 스택이 있다.
	• 예외 사례: 커널 스레드에는 스택이 하나뿐인 경우, 커널 모드 스택
	• 따라서 ch6/countem.sh 스크립트의 샘플 실행과 관련하여 정리해보면 다음과 같다.
		• 159개의 사용자 공간 스택(사용자 랜드에 있음).
		• 위와 더불어 159개의 커널 공간 스택(커널 메모리에 있음).
		• 위와 더불어 134개의 커널 공간 스택(활성 상태인 134개의 커널 스레드에 대해).
		• 이를 합치면 총 159 + 159 + 134 = 452개의 스택이 된다!  
        (64비트 Linux에서 커널 모드 스택당 4페이지, 페이지 크기를 4KB로 가정하면 스택 메모리에 사용되는 RAM은 4\*4096\*452 = 7.06MB이다.)  
		• FYI, grep "KernelStack" /proc/meminfo 명령은 현재 커널 스택에 사용되는 메모리 양을 보여준다. (자세한 내용은 proc(5)의 man 페이지를 참조)

## countmem2.sh script
책에느 안나와있지만, countmem2.sh스크립트를 뜯어보자.  
이전에 실행한 결과의 스레드 수와 다를 수 있다.(백그라운드로 동작하는 스레드 들이 있으므로)  
 - 모든 스레드 갯수는 2번(ps -LA)에 나온 것처럼 291개이다.  
 - 모든 커널 스레드의 갯수는 3번에 나온 것처럼 134개 이다.  
 - 모든 user mode 스레드의 갯수는 모든 스레드 갯수 - 커널 스레드 갯수, 즉, 2번 - 3번으로 157개이다.
 - 그러므로, user mode stack은 157개이다.
 - kernel mode stack은 아래 처럼 계산할 수 있다.  
 user mode thread 마다 kernel mode stack을 하나씩 갖고 있으므로: 4번 *2 == user mode thread number * 2  
 kernel thread는 kernel mode stack만 갖고 있으므로 3번 == kernel mode thread number  
 결국 3번 + (4번)*2  == kernel mode threads + (user mode threads) * 2 가 총 스택의 갯수가 된다.  
~~~bash
pi@raspberrypi:~/LKP_2E/ch6$ ./countem2.sh
1. Total # of processes alive                        =       199
2. Total # of threads alive                          =       291
3. Total # of kernel threads alive                   =       134
 (each kthread will have a kernel-mode stack)
4. Thus, total # of user mode threads = (2) - (3)    =       157
 (each uthread will have both a user and kernel-mode stack)
5. Thus, total # of kernel-mode stacks = (3) + (4)*2 =       448
pi@raspberrypi:~/LKP_2E/ch6$
~~~

## current MACRO(current_affairs.c), kernel, user context
~~~bash
pi@raspberrypi:~$ sudo dmesg -C
pi@raspberrypi:~$ sudo insmod ./current_affairs.ko; lsmod |grep current_affairs
current_affairs        12288  0
pi@raspberrypi:~$ sleep 1
pi@raspberrypi:~$ sudo rmmod current_affairs
pi@raspberrypi:~$ sudo dmesg
[   57.377318] current_affairs: loading out-of-tree module taints kernel.
[   57.378005] current_affairs:current_affairs_init(): inserted
[   57.378022] current_affairs:current_affairs_init(): sizeof(struct task_struct)=7872
[   57.378035] current_affairs:show_ctx():
[   57.378041] current_affairs:show_ctx(): we're running in process context ::
                name        : insmod
                PID         :   1609
                TGID        :   1609
                UID         :      0
                EUID        :      0 (have root)
                state       : R
                current (ptr to our process context's task_struct) :
                              0x00000000d0ddb808 (0xffffff80053abd80)
                stack start : 0x0000000062289b6c (0xffffffc082498000)
[   80.308874] current_affairs:show_ctx():
[   80.308898] current_affairs:show_ctx(): we're running in process context ::
                name        : rmmod
                PID         :   1638
                TGID        :   1638
                UID         :      0
                EUID        :      0 (have root)
                state       : R
                current (ptr to our process context's task_struct) :
                              0x00000000a7eaed86 (0xffffff801b283d80)
                stack start : 0x00000000413df3f4 (0xffffffc082588000)
[   80.308925] current_affairs:current_affairs_exit(): removed
~~~

insmod, rmmod를 해보면 name이 insmod, rmmod인 것을 볼 수 있다.  
코드를 보면, name이 (current->comm)  insmod, rmmod로 출력된다.  
PID, TGID가 가 같은데, 이건 main스레드라는 의미이다.  
원래 리눅스는 스레드 아이디만 있었으나 TGID는 POSIX표준을 맞추기 위해서 도입된 개념이라고 한다.  
이것들은 task_pid_nr, task_tgid_nr, current매크로로 가져오고 있다.
예제의 실행 결과는 결국 현재 컨텍스트의 이름을 출력하는 것이었고,  
커널 코드도 user context에서 실행된다는 것을 보여준다.  
~~~C
static inline void show_ctx(void)
{
	/* Extract the task UID and EUID using helper methods provided */
	unsigned int uid = from_kuid(&init_user_ns, current_uid());
	unsigned int euid = from_kuid(&init_user_ns, current_euid());

	pr_info("\n");		/* shows mod & func names (due to the pr_fmt()!) */
	if (likely(in_task())) {
		pr_info("we're running in process context ::\n"
			" name        : %s\n"
			" PID         : %6d\n"
			" TGID        : %6d\n"
			" UID         : %6u\n"
			" EUID        : %6u (%s root)\n"
			" state       : %c\n"
			" current (ptr to our process context's task_struct) :\n"
			"               0x%pK (0x%px)\n"
			" stack start : 0x%pK (0x%px)\n",
			current->comm,
			/* always better to use the helper methods provided */
			task_pid_nr(current), task_tgid_nr(current),
			/* ... rather than using direct lookups:
			 * current->pid, current->tgid,
			 */
			uid, euid,
			(euid == 0 ? "have" : "don't have"),
			task_state_to_char(current),
			/* Printing addresses twice- via %pK and %px
			 * Here, by default, the values will typically be the same as
			 * kptr_restrict == 1 and we've got root.
			 */
			current, current, current->stack, current->stack);
		/* FIXME- doesn't work
		   if (task_state_to_char(current) == 'R')
		   pr_info("on virtual CPU? %s\n", (current->flags & PF_VCPU)?"yes":"no");
		 */
	} else
		pr_alert("Whoa! running in interrupt context [Should NOT Happen here!]\n");
}
~~~
이 커널 모듈(ch6/current_affairs)의 핵심 요점은 Linux OS의 모놀리식 특성을 보여준다.  
insmod 작업을 수행했을 때 커널에 삽입되고 init 코드 경로가 실행되었다.  
누가 실행했을까? 출력을 보면, insmod 프로세스 자체가 프로세스 컨텍스트에서 모듈의 init 코드를 실행해서 Linux 커널의 모놀리식 특성을 증명했다!(rmmod 프로세스와 정리 코드 경로도 마찬가지이다. rmmod 프로세스가 프로세스 컨텍스트에서 실행했다.)  
  
마이크로커널 아키텍처는 아마도 모놀리식과는 정반대 접근 방식일 것입니다. 이 접근 방식은 메시지 전달 방식(시스템 호출 없음)으로, 메시지가 사용자 앱/프로세스에서 서버 프로세스로 전달*되고, 서버 프로세스가 작업을 수행합니다.  


