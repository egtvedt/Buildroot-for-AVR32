#!/bin/sh

led_path=none

for leds in /sys/class/leds/*; do
	# LED A on NGW100 or LED B1 on STK1000
	if [ "${leds}" = "/sys/class/leds/a" -o "${leds}" = "/sys/class/leds/b1:blue" ]; then
		led_path=${leds}
		led_brightness=`cat ${led_path}/brightness`
		led_trigger=`cat ${led_path}/trigger | cut -d ' ' -f1`
		break
	fi
done

if [ "${led_path}" != "none" ]; then
	if [ "${led_trigger}" = "[none]" ]; then
		echo heartbeat > ${led_path}/trigger
	else
		echo none > ${led_path}/trigger
	fi

fi

# Redirect back to top level
echo "HTTP/1.0 302 OK"
echo "Location: /"
