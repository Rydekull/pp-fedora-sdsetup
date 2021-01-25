#!/bin/bash

source .env

umount ${loop_device_fedora}p3
umount $PP_PARTB
umount $PP_PARTA
sleep 3
rmdir imgfs
rmdir rootfs
rmdir $KERNEL_RAW_DIR/imgfs
rmdir $KERNEL_RAW_DIR/rootfs
losetup -d ${loop_device_fedora}
losetup -d ${loop_device_phone}
