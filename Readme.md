# vagrant-devs

Vagrant + VirtualBox for building my development enviroment.

## Usage

    vagrant up


---

### Setting up extra HDDs

*After setting up the actual HDD via `VBoxManage`, view Vagrantfile for details.*

---


1. Get the dev path of the new drive.

        fdisk -l

  *Assumes drive is found on /dev/sdc*

2. Create a new partition.

        cfdisk /dev/sdc

  *Select `dos`*

3. Initialize the physical volume.

        pvcreate /dev/sdc1

4. Format the volume.

        mkfs.ext4 /dev/sdc1

5. Add to `/etc/fstab` for auto mounting:

        echo `blkid /dev/sdc1 | awk '{print$2}' | sed -e 's/"//g'` /mnt/path   ext4   noatime,nobarrier   0   0 >> /etc/fstab

  *Using `blkid`*

6. Then mount.

        mount /mnt/path
