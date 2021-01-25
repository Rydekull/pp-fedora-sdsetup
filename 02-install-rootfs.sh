#!/bin/bash
set -e

source .env

echo "===================="
echo "02-install-rootfs.sh"
echo "===================="

# Functions
infecho () {
    echo "[Info] $1"
}
errecho () {
    echo "[Error] $1" 1>&2
    exit 1
}

# Automatic Preflight Checks
if [[ $EUID -ne 0 ]]; then
    errecho "This script must be run as root!" 
    exit 1
fi

# Warning
echo "=== WARNING WARNING WARNING ==="
infecho "This script will try to mount to ${loop_device_fedora}."
infecho "The script detected this loop-device was unused, but we leave no warranties"
infecho "Please make a manual inspection of this output to ensure it isn't used already:"
echo "=== WARNING WARNING WARNING ==="
losetup
echo
read -p "Continue? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    infecho "Making mount directories..."
    mkdir -p imgfs
    mkdir -p rootfs

    infecho "Mounting Fedora image..."
    losetup ${loop_device_fedora} rawhide.raw
    partprobe -s ${loop_device_fedora}
    mount ${loop_device_fedora}p3 imgfs

    infecho "Mounting SD Card rootfs..."
    partprobe -s $PP_IMAGE
    sleep 1 # Sometimes it lags.
    mount $PP_PARTB rootfs

    infecho "Copying files..."
    rsync -a --progress imgfs/* rootfs/

    infecho "Deleting contents of /boot..."
    rm -rf rootfs/boot/*

    infecho "Unmounting everything..."
    umount ${loop_device_fedora}p3
    losetup -d ${loop_device_fedora}
    umount $PP_PARTB

    infecho "Deleting temp directories..."
    rmdir imgfs
    rmdir rootfs
fi

infecho "If there are no errors above, the script was probably successful!"
