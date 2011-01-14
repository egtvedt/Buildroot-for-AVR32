# Moved from /etc/inittab for more speed, cleanliness and flexibility.

# These filesystems are always required
/bin/mount -tproc procfs /proc
/bin/mount -tsysfs sysfs /sys

# Set up automatic /dev population with mdev, but first we need to
# create some standard static files, directories and symlinks.
/bin/mount -ttmpfs -osize=64k,mode=0755 mdevfs /dev
/bin/mkdir /dev/shm
/bin/mkdir /dev/pts
/bin/mount -tdevpts devpts /dev/pts
/bin/ln -s /proc/self/fd /dev/fd
/bin/ln -s /proc/self/fd/0 /dev/stdin
/bin/ln -s /proc/self/fd/1 /dev/stdout
/bin/ln -s /proc/self/fd/2 /dev/stderr
/bin/ln -s /proc/kcore /dev/core
/bin/echo /sbin/mdev > /proc/sys/kernel/hotplug
/sbin/mdev -s

# We don't want to keep temporary files across reboots
/bin/mount -ttmpfs tmpfs /tmp
/bin/mount -ttmpfs tmpfs /var/run
/bin/mount -ttmpfs tmpfs /var/lock

# If debugfs and/or configfs were enabled in the kernel, mount them now
if [ -d /sys/kernel/debug ]; then
	/bin/mount -tdebugfs debugfs /sys/kernel/debug
fi
if [ -d /sys/kernel/config ]; then
	/bin/mount -tconfigfs configfs /sys/kernel/config
fi

# Make sure log file(s) are created with the right permissions
/bin/touch /var/log/messages
/bin/chmod 0600 /var/log/messages

# Make LEDs accessible for all users
if [ -d /sys/class/leds ]; then
	chmod 0666 /sys/class/leds/*/brightness
	chmod 0666 /sys/class/leds/*/trigger
fi

# Don't show informational and debug messages on the console. They can
# still be retrieved with 'dmesg' and found in /var/log
/bin/dmesg -n6

# Set up basic networking so that we can start things like portmap and
# syslogd
/bin/hostname -F /etc/hostname
/sbin/ifconfig lo 127.0.0.1 up
/sbin/route add -net 127.0.0.0 netmask 255.0.0.0 lo
