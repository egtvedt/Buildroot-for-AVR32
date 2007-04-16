#! /bin/sh

echo -n " * local filesystems ...         "
if /bin/mount -a; then
	echo "[ OK ]"
else
	echo "[ FAILED ]"
	exit 1
fi
