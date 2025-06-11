#!/bin/bash

# Check if notify-send is available
if ! command -v notify-send &>/dev/null; then
  exit 1
fi

# Scan for LDM disk groups
DISKGROUP=$(sudo ldmtool scan | jq -r '.[0]')

if [ -z "$DISKGROUP" ] || [ "$DISKGROUP" == "null" ]; then
  notify-send --app-name="MountScript" -u critical "LDM Mount Error" "No LDM disk group found!"
  exit 1
fi

# Volume labels and mount points
VOL1_LABEL="Volume1"
VOL2_LABEL="Volume2"
MOUNT1="/mnt/kaushal/Tech"
MOUNT2="/mnt/kaushal/Non_Tech"

# Function to create and/or mount a volume
handle_volume() {
  local LABEL=$1
  local MOUNT_DIR=$2

  if mountpoint -q "$MOUNT_DIR"; then
    return 0
  fi

  local VOL_NAME
  VOL_NAME=$(ls /dev/mapper | grep -i "$LABEL" | head -n 1)

  if [ -z "$VOL_NAME" ]; then
    VOL_NAME=$(sudo ldmtool create volume "$DISKGROUP" "$LABEL" | jq -r '.[0]')
    if [ -z "$VOL_NAME" ] || [ "$VOL_NAME" == "null" ]; then
      notify-send --app-name="MountScript" -u critical "Mount Error" "Failed to create $LABEL"
      return 1
    fi
  fi

  if [ ! -e "/dev/mapper/$VOL_NAME" ]; then
    notify-send --app-name="MountScript" -u critical "Mount Error" "Device /dev/mapper/$VOL_NAME not found"
    return 1
  fi

  sudo mkdir -p "$MOUNT_DIR"
  sudo mount -t ntfs-3g "/dev/mapper/$VOL_NAME" "$MOUNT_DIR"

  if [ $? -eq 0 ]; then
    notify-send --app-name="Mount Script" "Mount Success" "$LABEL mounted at $MOUNT_DIR"
  else
    notify-send --app-name="Mount Script" -u critical "Mount Error" "Failed to mount $LABEL"
    return 1
  fi
}

# Run for both volumes
handle_volume "$VOL1_LABEL" "$MOUNT1"
handle_volume "$VOL2_LABEL" "$MOUNT2"
