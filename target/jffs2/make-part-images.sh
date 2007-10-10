#! /bin/sh

set -e

# Argument list:
#  Mandatory:
#   $1 : output basename for binaries (directory and filename).
#   $2 : target directory holding the entire file system.
#   $3 : staging directory.
#   $4 : JFFS2 partition setup file.
#   $5 : JFFS2 device file (only used on the partition named root.
#  Recommended:
#   $6 : JFFS2 options provided by the config system.

# Limitations
#  1) Not chained partitions (i.e. partitions mounted inside a partition).
#  2) No device file for other than the root image partition.
#  3) All paths shall be given with the full name.

#
# Helper function for error messages.
#
# \param $1 error message to print to the user before exiting the script.
#
die()
{
	echo "make-part-images.sh error:"
	echo "  ${@}"

	cleanup_end

	exit 1
}

#
# Helper function for warning messages.
#
# \param $1 warning message to print to the user.
#
warn()
{
	echo "make-part-images.sh warning:"
	echo "  ${1}"
}

#
# Checks if the partition file provided from user space is sane.
#   1) "root" partition exists.
#   2) Partitions has unique names.
#   3) Arguments for each partition seems to be sane.
#
# \param $1 path to partition file.
check_partition_file()
{
	local partition_file=$1
	local partition_names=""
	local name_unique=0
	local found_root=""

	if [ -z "${partition_file}" ]; then
		die "Internal error, no partition file"\
		    "provided to function check_partition_file()."
	fi

	echo "Checking partition file: ${partition_file}"

	grep '^[^#]' ${partition_file} > ${tmpdir}/partition_infos

	# Locate root partition and check setup for each partition.
	while read line; do
		local name=`echo ${line} | awk '{print $2}'`

		echo "  * found ${name}"

		if [ "${name}" = "root" ]; then
			found_root="yes"
			echo "    * which is root partition"
		fi

		if [ "${found_root}" != "yes" ]; then
			die "Could not find root partition in partition"\
			    "file '${partition_file}'"
		fi

		local page_size=`echo ${line} | awk '{print $3}'`
		local erase_size=`echo ${line} | awk '{print $4}'`
		local cleanmarkers=`echo ${line} | awk '{print $5}'`
		local device_file=`echo ${line} | awk '{print $6}'`
		local pad_size=`echo ${line} | awk '{print $7}'`

		if [ -z "${page_size}" ]; then
			die "Page size error for:"\
			    "'${partition_file}'::'${partition_name}'."
		fi
		if [ -z "${erase_size}" ]; then
			die "Erase size error for:"\
			    "'${partition_file}'::'${partition_name}'."
		fi
		if [ -z "${cleanmarkers}" ] || ( [ "${cleanmarkers}" != "0" ]\
				&& [ "${cleanmarkers}" != "1" ] ); then
			die "Cleanmarkers error for:"\
			    "'${partition_file}'::'${partition_name}'."
		fi
		if [ -z "${device_file}" ] || ( [ "${device_file}" != "0" ]\
				&& [ "${device_file}" != "1" ] ); then
			die "Device table error for:"\
			    "'${partition_file}'::'${partition_name}'."
		fi
		if [ -z "${pad_size}" ]; then
			die "Pad size error for:"\
			    "'${partition_file}'::'${partition_name}'."
		fi
	done < ${tmpdir}/partition_infos

	partition_names=`grep '^[^#]' ${partition_file} | awk '{print $2}'`

	# Check that each name is unique for the partitions.
	for name1 in ${partition_names}; do
		for name2 in ${partition_names}; do
			if [ "${name1}" = ${name2} ]; then
				name_unique=$((${name_unique} + 1))
			fi
		done
		if [ $name_unique -gt 1 ]; then
			die "Partition '${name1}' is not unique in "\
			    "partition file '${partition_file}'"
		fi
		name_unique=0
	done
}

#
# Cleanup temporary files for partitions.
#
cleanup_temp_files()
{
	if ! rm -f ${staging_dir}/_fakeroot.*; then
		die "Failed deleting temporary fakeroot files for partitions."
	fi
	if ! rm -rf ${tmpdir}/root; then
		die "Failed deleting temporary root directory"\
		    "'${tmpdir}/root'."
	fi
}

#
# Helper function which cleans files from previouse image creations.
#
cleanup_start()
{
	cleanup_temp_files

	if ! rm -rf ${tmpdir}; then
		die "Failed deleting temporary directory '${tmpdir}'."
	fi
}

#
# Clean up function after creating images or failed.
#
cleanup_end()
{
	cleanup_temp_files

	if ! rm -rf ${tmpdir}; then
		die "Failed deleting temporary directory."
	fi
}

#
# Generic function to get the JFFS2 options for a given mount point from the
# partition setup file.
#
# \param $1 Name of partition.
#
# \sets partition_jffs2_options JFFS2 specific options for this partition.
#
get_partition_jffs2_options()
{
	local partition_name=$1

	if [ -z "${partition_name}" ]; then
		die "Internal error, no partition name provided to"\
		    "function get_partition_jffs2_options()."
	fi

	echo "Processing partition: ${partition_name}"

	# reset variables
	partition_jffs2_options=${jffs2_options}
	local partition_info=""

	# Fetch line from partition information file
	grep '^[^#]' ${partition_file} | grep ${partition_name}\
		> ${tmpdir}/partition_infos

	while read line; do
		name=`echo ${line} | awk '{print $2}'`
		if [ "${name}" = "$partition_name" ]; then
			partition_info="${line}"
			break;
		fi
	done < ${tmpdir}/partition_infos

	if [ -z "$partition_info" ]; then
		die "Internal error, could not find information"\
		    "about partition '${partition_name}'."
	fi

	# ${partition_info} now contains useful information we want to process
	# and set final configuration for the partition before returning.
	local page_size=`echo ${partition_info} | awk '{print $3}'`
	local erase_size=`echo ${partition_info} | awk '{print $4}'`
	local cleanmarkers=`echo ${partition_info} | awk '{print $5}'`
	local device_file=`echo ${partition_info} | awk '{print $6}'`
	local pad_size=`echo ${partition_info} | awk '{print $7}'`

	partition_jffs2_options="${partition_jffs2_options}\
				 --pagesize=${page_size}\
				 --eraseblock=${erase_size}"

	if [ ${cleanmarkers} -eq 0 ]; then
		partition_jffs2_options="${partition_jffs2_options}\
					 --no-cleanmarkers"
	fi

	if [ ${device_file} -eq 1 ]; then
		partition_jffs2_options="${partition_jffs2_options}\
					 --devtable=${device_table_file}"
	fi

	if [ "${pad_size}" = "-1" ]; then
		:
	elif [ "${pad_size}" = "0" ] || [ "${pad_size}" = "0x0" ]; then
		partition_jffs2_options="${partition_jffs2_options} --pad"
	else
		partition_jffs2_options="${partition_jffs2_options}\
					 --pad=${pad_size}"
	fi

	# Remove annoing tabs in partition_jffs2_options
	partition_jffs2_options=`echo ${partition_jffs2_options} | sed 's/\t//g'`
}

#
# Function to get the partition path from a given partition name.
#
# \param $1 Name of partition.
#
# \sets partition_path Path to the partition.
#
get_partition_path()
{
	local partition_name=$1

	if [ -z "${partition_name}" ]; then
		die "Internal error, no partition name provided to"\
		    "function get_partition_path()."
	fi

	# reset variable
	partition_path=""

	# Fetch line from partition information file
	grep '^[^#]' ${partition_file} | grep ${partition_name}\
		> ${tmpdir}/partition_infos

	while read line; do
		local name=`echo ${line} | awk '{print $2}'`
		if [ "${name}" = "$partition_name" ]; then
			partition_path=`echo ${line} | awk '{print $1}'`
			break;
		fi
	done < ${tmpdir}/partition_infos

	if [ -z "$partition_path" ]; then
		die "Internal error, could not find partition path"\
		    "for partition '${partition_name}'."
	fi
}

create_jffs2_image()
{
	local partition_name=$1

	if [ -z "${partition_name}" ]; then
		die "Internal error, no partition name provided to"\
		    "function create_jffs2_image()."
	fi

	# Function sets partition_jffs2_options variable.
	get_partition_jffs2_options ${partition_name}

	if ! touch ${staging_dir}/_fakeroot.rootfs.jffs2.${partition_name}; then
		die "Could not create _fakeroot file."
	fi

	# Function sets partition_path variable.
	get_partition_path ${partition_name}

	echo "chown -R 0:0 ${target_dir}/${partition_path}"\
		>> ${staging_dir}/_fakeroot.rootfs.jffs2.${partition_name}

	# Use makedevs on the root file system.
	if [ "${partition_name}" = "root" ]; then
		echo "${staging_dir}/bin/makedevs -d ${device_table_file}"\
			"${tmpdir}/${partition_name}"\
			>> ${staging_dir}/_fakeroot.rootfs.jffs2.${partition_name}
	fi

	# The root file system has another root directory than the others.
	if [ "${partition_name}" = "root" ]; then
		echo "${mkfsjffs2} ${partition_jffs2_options}"\
			"--root=${tmpdir}/${partition_name}"\
			"--output=${output_base}-${partition_name}"\
			>> ${staging_dir}/_fakeroot.rootfs.jffs2.${partition_name}
	else
		echo "${mkfsjffs2} ${partition_jffs2_options}"\
			"--root=${target_dir}/${partition_path}"\
			"--output=${output_base}-${partition_name}"\
			>> ${staging_dir}/_fakeroot.rootfs.jffs2.${partition_name}
	fi

	if ! chmod 0755 ${staging_dir}/_fakeroot.rootfs.jffs2.${partition_name}; then
		die "Could not make _fakeroot file executable."
	fi

	if ! ${staging_dir}/usr/bin/fakeroot -- \
		${staging_dir}/_fakeroot.rootfs.jffs2.${partition_name}; then
		die "Fakeroot failed for partition '${partition_name}'."
	fi
}

#
# Fetch variables from user space
#
output_base=$1
target_dir=$2
staging_dir=$3
partition_file=$4
device_table_file=$5
if [ ${#} -eq 6 ]; then
	jffs2_options=$6
else
	jffs2_options=""
fi

#
# Sanity check of incoming variables.
#
if [ ${#} -lt 5 ] || [ -z "${output_base}" ] || [ -z "${target_dir}" ]\
	   || [ -z "${partition_file}" ] || [ -z "${device_table_file}" ]\
	   || [ -z "${staging_dir}" ]; then
	echo "Usage: make-part-images.sh [output basename]"
	echo "		[target directory] [staging directory]"
	echo "		[partition file] [device file] <JFFS2 options>"
	return 1
fi

touch "${output_base}"
if [ ! -f "${output_base}" ]; then
	die "Output basename '${output_base}' does not exist."
fi

if [ ! -d "${target_dir}" ]; then
	die "Target directory '${target_dir}' does not exist."
fi

if [ ! -d "${staging_dir}" ]; then
	die "Staging directory '${staging_dir}' does not exist."
fi

if [ ! -s "${partition_file}" ]; then
	die "Partition file '${partition_file}' does not exist, or is 0 bytes."
fi

if [ ! -f "${device_table_file}" ]; then
	die "Device file '${device_table_file}' does not exist."
fi

# Define a temporary working directory after ${staging_dir} is sane.
tmpdir=${staging_dir}/.tmp

# Clean up after previouse failed runs.
cleanup_start

# Make a temporary work directory.
if ! mkdir -p "${tmpdir}" ; then
	die "Could not create temporary directory '${tmpdir}'."
fi

#
# Check the partition file provided from user space.
#
check_partition_file ${partition_file}

#
# We are quite sane, we can set variables safely.
#
sub_partitions=`grep '^[^#]' ${partition_file} |\
	       grep -v root | awk '{print $2}'`
sub_partitions_paths=`grep '^[^#]' ${partition_file} |\
		     grep -v root | awk '{print $1}'`

mkfsjffs2=`find ./toolchain* -name mkfs\.jffs2 -type f -perm +a+x`
if [ ! -x "${mkfsjffs2}" ]; then
	die "Could not locate an executable mkfs.jffs2 tool."
else
	echo "Using mkfs.jffs2 at location '${mkfsjffs2}'"
fi

#
# Copy root partition and move away each of the "sub" partitions, remake empty
# directories to be able to mount the "sub" partitions and build the root
# partition image.
#
if ! cp -dpfr ${target_dir} ${tmpdir}; then
	die "Could not copy root directory to temporary directory."
fi
if ! ${staging_dir}/bin/ldconfig -r ${tmpdir}/root; then
	warn "Could not run ldconfig -r '${tmpdir}/root."
fi

#
# Remove sub partitions from root partition.
#
for sub_partition in ${sub_partitions_paths}; do
	if [ -d ${sub_partition} ]; then
		if ! rm -rf ${tmpdir}/root/${sub_partition}; then
			die "Could not delete sub partition"\
			    "'${sub_partition}' on temporary root file system."
		fi
		if ! mkdir -p ${tmpdir}/root/${sub_partition}; then
			die "Could not make sub directory"\
			    "'${sub_partition}' on temporary root file system."
		fi
	else
		die "Sub partition '${sub_partition}' does"\
		    "not exist on root file system."
	fi
done

create_jffs2_image "root"
cleanup_temp_files

#
# Make partiton images of the "sub" partitions.
#
for partition in ${sub_partitions}; do
	create_jffs2_image ${partition}
	cleanup_temp_files
done

cleanup_end

return 0
