#!/usr/bin/env bash
# This bootstraps Docker on CentOS 6.x
# It has been tested on CentOS 6.4 64bit
# Based on https://docs.oracle.com/cd/E37670_01/E37355/html/section_kfy_f2z_fp.html#
# Based on Oracle® Linux Administrator's Solutions Guide for Release 6

set -e
/usr/bin/wget --no-check-certificate -q https://yum.dockerproject.org/gpg -O /etc/pki/rpm-gpg/RPM-GPG-KEY-docker
sudo tee /etc/yum.repos.d/docker.repo <<-EOF
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/oraclelinux/6
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-docker
EOF
# Install Docker...
echo "Installing docker"
sudo yum -y install docker-engine > /dev/null

echo "Docker installed!"
sudo service docker start
sudo chkconfig docker on
sudo yum -y install btrfs-progs > /dev/null