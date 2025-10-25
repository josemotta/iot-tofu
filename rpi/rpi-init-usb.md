## Cleaning and formatting ext4 USB drive

### Identify the USB drive listing all storage devices connected to your computer:

lsblk -f

Look for its size, name (e.g., sdb, sdc), and any partitions (e.g., sdb1). Your device name will be the root device, such as /dev/sdb, not the partition number. Mistyping this can erase the wrong disk.

### Unmount the drive, replacing sdX1 with your USB's partition name

sudo umount /dev/sdX1

### Wipe the entire disk (optional, for secure erase)

To erase the entire disk by overwriting it with zeros, use the dd command. This is a slow, irreversible process. Replace sdX with your USB's device name.

sudo dd if=/dev/zero of=/dev/sdX bs=1M status=progress

For a faster, but less secure wipe, you can use the wipefs command to remove the old filesystem signature. Replace sdX1 with your USB's partition name.

sudo wipefs -a /dev/sdX1

### Create a new partition table with fdisk

sudo fdisk /dev/sdX

### Format the new partition.

Format the partition with the ext4 filesystem. Replace sdX1 with your USB's partition name:

sudo mkfs.ext4 /dev/sdX1

### Eject the drive.

sudo eject /dev/sdX
