#!/bin/bash
set -e

source .env

echo "====================="
echo "01-partition-drive.sh"
echo "====================="

# Functions
infecho () {
    echo "[Info] $1"
}
errecho () {
    echo $1 1>&2
}

# Automatic Preflight Checks
if [[ $EUID -ne 0 ]]; then
    errecho "This script must be run as root!" 
    exit 1
fi

# Warning
echo "=== WARNING WARNING WARNING ==="
infecho "This script will try to mount to ${loop_device_phone}."
infecho "The script detected this loop-device was unused, but we leave no warranties" 
infecho "Please make a manual inspection of this output to ensure it isn't used already:"
echo "=== WARNING WARNING WARNING ==="
losetup
echo
read -p "Continue? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    infecho "Begining image partition..."
    sfdisk $OUT_NAME <<EOF
label: dos
unit: sectors

4MiB,252MiB,
256MiB,,
EOF
    infecho "Image partitioned!"

    infecho "Mounting the image to loop1..."
    loop_device_phone=$(losetup -f)
    losetup ${loop_device_phone} fedora.img
    partprobe -s ${loop_device_phone}

    infecho "Beginning filesystem creation..."
    infecho "If this fails, you might need to install mkfs.f2fs, which is usually called f2fs-tools."
    mkfs.vfat -n BOOT $PP_PARTA
    mkfs.f2fs -f -l ROOT $PP_PARTB
    infecho "Filesystems created!"
fi

infecho "If there are no errors above, the script was probably successful!"
