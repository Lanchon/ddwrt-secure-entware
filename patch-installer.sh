#!/bin/sh

# Author: Lanchon

set -eu

sed -i 's/http:/https:/g' "$1"
sed -i "s|/opt/bin/opkg update|sed -i 's/http:/https:/g' /opt/etc/opkg.conf\n/opt/bin/opkg update|" "$1"
