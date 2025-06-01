#!/bin/bash

# Scan for LDM disk groups
DISKGROUP=$(sudo ldmtool scan | jq -r '.[0]')

if [ -z "$DISKGROUP" ]; then
  echo "Error: No LDM disk group found!"
  exit 1
fi

echo "LDM Disk Group: $DISKGROUP"

# Create the volume for Volume1 and Volume2
VOL1_NAME=$(sudo ldmtool create volume "$DISKGROUP" Volume1 | jq -r '.[0]')
VOL2_NAME=$(sudo ldmtool create volume "$DISKGROUP" Volume2 | jq -r '.[0]')

if [ -z "$VOL2_NAME" ] || [ "$VOL2_NAME" == "null" ]; then
  echo "Error: Failed to create Volume2!"
  exit 1
fi

echo "Created Volume: $VOL2_NAME"

MOUNT_POINT="/mnt/kaushal/Tech"

# Unmount if already mounted
if mountpoint -q "$MOUNT_POINT"; then
  echo "Unmounting existing mount at $MOUNT_POINT..."
  sudo umount "$MOUNT_POINT"
fi

# Ensure the volume exists in /dev/mapper before mounting
if [ ! -e "/dev/mapper/$VOL2_NAME" ]; then
  echo "Error: Device mapper entry /dev/mapper/$VOL2_NAME does not exist!"
  exit 1
fi

# Create the mount directory if it doesn't exist
sudo mkdir -p "$MOUNT_POINT"

# Mount the volume
echo "Mounting $VOL2_NAME to $MOUNT_POINT..."
sudo mount -t ntfs-3g /dev/mapper/"$VOL2_NAME" "$MOUNT_POINT"

if [ $? -eq 0 ]; then
  echo "Mount successful!"
else
  echo "Error: Failed to mount $VOL2_NAME!"
fi
