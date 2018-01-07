#!/bin/bash

apt-get -y update
apt-get -y dist-upgrade
apt-get -y install software-properties-common

echo 'ubuntu ALL=NOPASSWD:ALL' > /etc/sudoers.d/ubuntu