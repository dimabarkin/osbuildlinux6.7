#!/usr/bin/env bash
# This bootstraps Docker on CentOS 6.x
# It has been tested on CentOS 6.4 64bit
# Based on https://docs.oracle.com/cd/E37670_01/E37355/html/section_kfy_f2z_fp.html#
# Based on Oracle® Linux Administrator's Solutions Guide for Release 6

set -e

sudo puppet module install /tmp/puppetlabs-inifile-1.4.3.tar.gz --ignore-dependencies && puppet apply /tmp/predocker.pp && yum -y update && reboot
