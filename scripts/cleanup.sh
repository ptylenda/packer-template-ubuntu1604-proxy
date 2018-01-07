#!/bin/bash

purge-old-kernels
apt-get -y autoremove --purge
apt-get -y clean

rm -rf /tmp/*

dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

sync