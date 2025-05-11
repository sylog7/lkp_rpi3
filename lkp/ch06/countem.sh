#!/bin/bash
# countem.sh
# ***************************************************************
# * This program is part of the source code released for the book
# *  "Linux Kernel Programming", 2nd Ed
# *  (c) Author: Kaiwan N Billimoria
# *  Publisher:  Packt
# *  GitHub repository:
# *  https://github.com/PacktPublishing/Linux-Kernel-Programming_2E
# *
# * From: Ch 6 : Kernel and Memory Management Internals Essentials
# ****************************************************************
# * Brief Description:
# * Counts the total number of processes, user and kernel threads currently
# * alive on the system.
# * For details, please refer the book, Ch 6.
# ****************************************************************
set -euo pipefail
echo "System release info:"
which lsb_release >/dev/null && lsb_release -a || true
[[ -f /etc/issue ]] && cat /etc/issue
[[ -f /etc/os-release ]] && cat /etc/os-release

total_prcs=$(ps -A|wc -l)
printf "\nTotal # of processes alive               = %9d\n" ${total_prcs}

# ps -LA shows all threads
total_thrds=$(ps -LA|wc -l)
printf "Total # of threads alive                 = %9d\n" ${total_thrds}

# ps aux shows all kernel threads names (col 11) in square brackets; count 'em
total_kthrds=$(ps aux|awk '{print $11}'|grep "^\["|wc -l)

printf "Total # of kernel threads alive          = %9d\n" ${total_kthrds}
printf "Thus, total # of user mode threads alive = %9d\n" $((${total_thrds}-${total_kthrds}))

exit 0
