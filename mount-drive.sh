echo "Enter the drive path: "
read drive
sudo umount -f $drive
sudo ntfsfix $drive
sudo mkdir -p /mnt/kaushal/$drive
sudo mount -t ntfs-3g $drive /mnt/kaushal/$drive

