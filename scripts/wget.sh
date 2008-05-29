#!/bin/sh

# This scripts will try to download the source package from the upstream site,
# but if that fails it will try to download the file from a given mirror site.

# Syntax : wget.sh [mirror site] [wget options] [source code URL]
# Example: wget.sh http://mymirror.com/buildroot --passive-ftp http://url.to/some/software.tar.bz2

WGET_BIN=$(which wget)
AWK_BIN=$(which awk)

if [ ! -x $WGET_BIN ]; then
	echo "Could not find wget, please install 'wget' on your system."
	exit 1
fi

if [ ! -x $AWK_BIN ]; then
	echo "Could not find awk, please install 'awk' on your system."
	exit 1
fi

wget_args=
wget_mirror=$1

# Shift away the wget mirror site
shift 1

index=1
end=$#

# Get the wget arguments and assume that the last argument is the URL
# to the source code to be downloaded.
while true; do
	if [ $index -ge $end ]; then
		source_file_url=$1
		break;
	fi

	wget_args=$(echo $wget_args $1)

	index=$(($index + 1))
	shift 1
done

source_filename=$source_file_url

# Get the source code file name to use when grabbing the source code from the
# mirror site. The file name is assumed to be everything after the last slash.
while true; do
	slash_position=$(echo $source_filename | $AWK_BIN '{print match($0, "/")}')

	# No more /'es in the URL, we have the filename or nothing at all.
	if [ $slash_position -eq 0 ]; then
		break;
	fi

	source_filename=$(echo $source_filename | $AWK_BIN '{print substr($0, 2)}')
done

# Make sure we found something at all as file name for the source code.
if [ -z $source_filename ]; then
	echo "Could not extract the source file name from"
	echo "the URL '$source_file_url'."
	echo "The mirroring system needs to know the file name to be able"
	echo "to download the tarball."
	exit 1
fi

# Try to download from the regular site first.
if $WGET_BIN $wget_args $source_file_url; then
	exit $?
fi

# If regular site failed we try the mirror site instead.
echo "Failed to download, trying mirror"
echo "$WGET_BIN $wget_args $wget_mirror/$source_filename"
$WGET_BIN $wget_args $wget_mirror/$source_filename
