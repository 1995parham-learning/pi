#!/usr/bin/env bash
# Drive a GPIO line using libgpiod v2 (gpioset).
# The sysfs /sys/class/gpio interface was removed upstream; libgpiod is the
# current best practice for userspace GPIO on Raspberry Pi.
#
# Install: pacman -S libgpiod   (Arch)   |   apt install gpiod   (Debian/RPi OS)

set -euo pipefail

usage() {
	echo "usage: $0 <gpio-line e.g. 26> <value 0|1> [hold-duration e.g. 2s]"
	echo "       line may be a number (26) or a named line (GPIO26)"
}

if [[ $# -lt 2 ]]; then
	usage
	exit 1
fi

if ! command -v gpioset >/dev/null 2>&1; then
	echo "gpioset not found; install libgpiod (package: libgpiod or gpiod)" >&2
	exit 1
fi

line="$1"
value="$2"
hold="${3:-}"

# Accept bare numbers by mapping them to the named line (works across Pi 3/4/5
# regardless of which gpiochipN exposes the header pins).
if [[ "$line" =~ ^[0-9]+$ ]]; then
	line="GPIO${line}"
fi

if [[ "$value" != "0" && "$value" != "1" ]]; then
	usage
	exit 1
fi

if [[ -n "$hold" ]]; then
	# --hold-period keeps the line driven for the given duration before release.
	exec gpioset --hold-period "$hold" -t0 "${line}=${value}"
fi

exec gpioset "${line}=${value}"
