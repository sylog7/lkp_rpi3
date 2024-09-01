#!/bin/sh
docker stop raspi_linux-sdk
docker rm raspi_linux-sdk
docker run -it --privileged -e "TZ=Asia/Seoul" -e "TERM=xterm-256color" --privileged --network=host -v /etc/localtime:/etc/localtime --device="/dev/sda1:/dev/sda1" --device="/dev/sda2:/dev/sda2" --volume="$PWD/..:/home/raspi_linux/kernel" -u raspi_linux --name raspi_linux-sdk raspi_linux-sdk:v1
