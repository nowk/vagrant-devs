Basic instructions to setup the secondary drive.


Get the dev path of the new drive

    fdisk -l

*Assumes drive is found on /dev/sdc*

Create a new partition

    cfdisk /dev/sdc

*Select `dos`*

Initialize the physical volume

    pvcreate /dev/sdc1

Format the volume

    mkfs.ext4 /dev/sdc1


Add to `/etc/fstab` for auto mounting

    echo `blkid /dev/sdc1 | awk '{print$2}' | sed -e 's/"//g'` /mnt/path   ext4   noatime,nobarrier   0   0 >> /etc/fstab`"'`

*Using `blkid`*

Mount or reboot

    mount /mnt/path
