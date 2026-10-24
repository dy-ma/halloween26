#!/bin/sh
set -eu

if [ "$(id -u)" -ne 0 ]; then
  echo "Run with sudo: sudo sh $0" >&2
  exit 1
fi

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
if ! command -v mosquitto >/dev/null 2>&1 || ! command -v mosquitto_sub >/dev/null 2>&1; then
  apt-get update
  apt-get install -y mosquitto mosquitto-clients
fi

install -m 0644 "$script_dir/mosquitto-test.conf" /etc/mosquitto/conf.d/halloween-test.conf
systemctl enable mosquitto.service
systemctl restart mosquitto.service
systemctl --no-pager --full status mosquitto.service
