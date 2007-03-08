#! /bin/sh

echo -n " * setting up mdev ...           "
set -e
trap 'echo "[ FAILED ]"' EXIT
/bin/mount -t proc proc /proc
/bin/mount -t sysfs sys /sys
/bin/mount -t tmpfs -o size=512k,mode=0755 mdev /dev
/bin/mkdir /dev/shm
/bin/mkdir /dev/pts
/bin/ln -s /proc/self/fd /dev/fd
/bin/ln -s /proc/self/fd/0 /dev/stdin
/bin/ln -s /proc/self/fd/1 /dev/stdout
/bin/ln -s /proc/self/fd/2 /dev/stderr
/bin/ln -s /proc/kcore /dev/core
/bin/mount -t devpts devpts /dev/pts
/bin/echo /sbin/mdev > /proc/sys/kernel/hotplug
/sbin/mdev -s
trap - EXIT
echo "[ OK ]"
