#! /bin/sh

echo -n " * stopping networking ...       "
if /sbin/ifdown -a; then
	echo "[ OK ]"
else
	echo "[ FAILED ]"
	exit 1
fi
