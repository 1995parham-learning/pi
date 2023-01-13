#!/bin/bash
usage() {
	echo "$0 <led e.g. 26> <value e.g. 1 0>"
}

if [[ $UID -ne 0 ]]; then
	echo "you must run this script with root"
	exit 1
fi

if [[ $# -lt 2 ]]; then
	usage
	exit 1
fi

echo "exporting pin $1"
echo "$1" >/sys/class/gpio/export || true

echo "setting direction to out"
echo "out" >"/sys/class/gpio/gpio$1/direction"

echo "setting pin $2"
echo "$2" >"/sys/class/gpio/gpio$1/value"
