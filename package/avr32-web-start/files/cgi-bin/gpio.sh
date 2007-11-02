#!/bin/sh

led_path=none

for leds in /sys/class/leds/*; do
	# LED A on NGW100 or LED B1 on STK1000
	if [ "${leds}" = "/sys/class/leds/a" -o "${leds}" = "/sys/class/leds/b1:blue" ]; then
		led_path=${leds}
		led_brightness=`cat ${led_path}/brightness`
		break
	fi
done

if [ "${led_path}" != "none" ]; then
	if [ ${led_brightness} -eq 0 ]; then
		echo 255 > ${led_path}/brightness
	else
		echo 0 > ${led_path}/brightness
	fi
fi

# Redirect back to top level
echo "HTTP/1.0 302 OK"
echo "Location: /"
