#!/bin/sh
set -e
apt-get update || true
apt-get dist-upgrade -y
