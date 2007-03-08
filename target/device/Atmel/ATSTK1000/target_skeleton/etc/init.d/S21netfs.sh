#! /bin/sh

echo -n " * remote filesystems ...        "
if /bin/mount -t nfs -a; then
	echo "[ OK ]"
else
	echo "[ FAILED ]"
	exit 1
fi
