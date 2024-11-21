#!/bin/sh

USER_NAME=raspi_linux
CONTAINER_HOME=/home/${USER_NAME}
CONTAINER_NAME=raspi_linux-sdk
VERSION=v1
TAG_NAME=${CONTAINER_NAME}:${VERSION}

docker stop ${CONTAINER_NAME}
docker rm ${CONTAINER_NAME}
docker run -it --privileged -e "TZ=Asia/Seoul" \
    -e "TERM=xterm-256color" \
    --network=host \
    -v /etc/localtime:/etc/localtime \
    --device="/dev/sdc1:/dev/sdc1" \
    --device="/dev/sdc2:/dev/sdc2" \
    --volume="$PWD/..:/${CONTAINER_HOME}/kernel" \
    -u ${USER_NAME} \
    --name ${CONTAINER_NAME} ${TAG_NAME}
