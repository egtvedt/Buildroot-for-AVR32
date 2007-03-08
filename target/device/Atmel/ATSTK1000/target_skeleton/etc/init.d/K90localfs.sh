#! /bin/sh

exec 9<&0 < /proc/mounts

REG_MTPTS=""
TMPFS_MTPTS=""
while read DEV MTPT FSTYPE REST; do
	case "$MTPT" in
	/|/proc|/dev|/dev/pts|/sys)
		continue
		;;
	esac
	case "$FSTYPE" in
	tmpfs)
		TMPFS_MTPTS="$TMPFS_MTPTS $MTPT"
		;;
	*)
		REG_MTPTS="$REG_MTPTS $MTPT"
		;;
	esac
done

exec 0<&9 9<&-

# Unmount tmpfs file systems before turning off swap
if [ "$TMPFS_MTPTS" ]; then
	echo -n " * unmount tmpfs filesystems ... "
	if /bin/umount $TMPFS_MTPTS; then
		echo "[ OK ]"
	else
		echo "[ FAILED ]"
	fi
fi

echo -n " * deactivate swap ...           "
if /sbin/swapoff -a; then
	echo "[ OK ]"
else
	echo "[ FAILED ]"
fi

if [ "$REG_MTPTS" ]; then
	echo -n " * unmount local filesystems ... "
	if /bin/umount -f -r $REG_MTPTS; then
		echo "[ OK ]"
	else
		echo "[ FAILED ]"
		exit 1
	fi
fi
