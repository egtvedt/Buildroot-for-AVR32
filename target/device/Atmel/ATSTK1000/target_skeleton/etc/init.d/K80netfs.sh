#! /bin/sh

exec 9<&0 < /proc/mounts
DIRS=""
while read DEV MTPT FSTYPE OPTS REST; do
	case "$MTPT" in
	/)
		continue
	esac
	case "$FSTYPE" in
	nfs|nfs4|smbfs|ncp|ncpfs|cifs|coda|ocfs2|gfs)
		DIRS="$MTPT $DIRS"
		;;
	esac
done

exec 0<&9 9<&-

if [ "$DIRS" ]; then
	echo -n " * unmount net filesystems ...  "
	if /bin/umount -f -l $DIRS; then
		echo "[ OK ]"
	else
		echo "[ FAILED ]"
		exit 1
	fi
fi
