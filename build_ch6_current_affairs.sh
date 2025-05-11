#!/bin/bash

echo "--- Set env variables ---"

. build.sh --env

cd $TOP_DIR/lkp/ch06/current_affairs

make clean
make


echo "--- Done ---"

