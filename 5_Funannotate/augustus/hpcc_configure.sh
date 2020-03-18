#!/bin/bash

make clean
CXXFLAGS="-I/opt/linux/centos/7.x/x86_64/src/bamtools/include -L/opt/linux/centos/7.x/x86_64/src/bamtools/lib" make -j 2
