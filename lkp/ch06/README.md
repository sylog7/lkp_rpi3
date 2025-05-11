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
• 작업 구조(Task structures):
	• 모든 활성 스레드(사용자 또는 커널)는 커널에 해당 작업 구조(struct task_struct)를 가지고 있다. 이것이 커널이 스레드를 추적하고 관리하는 방식이다.
	• ch6/countem.sh 스크립트:
		• 시스템에 활성 스레드(사용자 및 커널 모두)가 총 293개이므로 커널 메모리에 총 293개의 task_struct(메타데이터)가 있음을 의미한다.(코드에서는 struct task_struct). 다음과 같이 말할 수 있다.
		• 이러한 task struct 중 159개는 사용자 스레드를 나타낸다.
		• 나머지(293 - 159 =) 134개의 task struct는 커널 스레드의 task struct를 나타낸다.  
• 스택:
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


