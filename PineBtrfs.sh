

## Formating Partition and Getting UUID from them

    clear
    lsblk
    echo -ne "-
Carefull all data on this partition is going to be deleted
-"
    read -p "Please enter your BOOT partition : /dev/" partition1
    mkfs.ext4 -L PINEBOOT /dev/$partition1
    BOOTUUID=$(blkid -o value -s UUID /dev/$partition1)
    clear
    lsblk
    echo -ne "-
Carefull all data on this partition is going to be deleted
-"
    read -p "Please enter your Root partition : /dev/" partition2
    mkfs.btrfs -L PINEROOT -m single -f /dev/$partition2
    ROOTUUID=$(blkid -o value -s UUID /dev/$partition2)
    clear


   #Mounting Root on /mnt to create Btrfs Subvolumes
    mount UUID=${ROOTUUID} /mnt


   
    btrfs subvolume create /mnt/@
	btrfs subvolume create /mnt/@/.snapshots
	mkdir /mnt/@/.snapshots/1
	btrfs subvolume create /mnt/@/.snapshots/1/snapshot
	mkdir /mnt/@/boot
	btrfs subvolume create /mnt/@/opt
	btrfs subvolume create /mnt/@/root
	btrfs subvolume create /mnt/@/srv
	btrfs subvolume create /mnt/@/tmp
	mkdir /mnt/@/usr
	btrfs subvolume create /mnt/@/usr/local
	mkdir /mnt/@/var
	btrfs subvolume create /mnt/@/var/cache
	btrfs subvolume create /mnt/@/var/log
	btrfs subvolume create /mnt/@/var/spool
	btrfs subvolume create /mnt/@/var/tmp
	NOW=$(date +"%Y-%m-%d %H:%M:%S")
	sed -i "s|2022-01-01 00:00:00|${NOW}|" info.xml
	cp info.xml /mnt/@/.snapshots/1/info.xml
  	btrfs subvolume set-default $(btrfs subvolume list /mnt | grep "@/.snapshots/1/snapshot" | grep -oP '(?<=ID )[0-9]+') /mnt
	btrfs quota enable /mnt
	chattr +C /mnt/@/var/cache
	chattr +C /mnt/@/var/log
	chattr +C /mnt/@/var/spool
	chattr +C /mnt/@/var/tmp

# unmount root to remount with subvolume
    umount /mnt

# mount @ subvolume
    mount UUID=${ROOTUUID} -o compress=zstd /mnt

# make directories home, .snapshots, var, tmp

	mkdir /mnt/.snapshots
	mkdir /mnt/opt
	mkdir /mnt/root
	mkdir /mnt/srv
	mkdir /mnt/tmp
	mkdir -p /mnt/usr/local
	mkdir -p /mnt/var/cache
	mkdir /mnt/var/log
	mkdir /mnt/var/spool
	mkdir /mnt/var/tmp
	mkdir /mnt/boot
	mkdir /mnt/home


# mount subvolumes and partition

    mount UUID=${ROOTUUID} -o noatime,compress=zstd,ssd,commit=120,subvol=@/.snapshots /mnt/.snapshots
    mount UUID=${ROOTUUID} -o noatime,compress=zstd,ssd,commit=120,subvol=@/opt /mnt/opt
    mount UUID=${ROOTUUID} -o noatime,compress=zstd,ssd,commit=120,subvol=@/root /mnt/root
    mount UUID=${ROOTUUID} -o noatime,compress=zstd,ssd,commit=120,subvol=@/srv /mnt/srv
    mount UUID=${ROOTUUID} -o noatime,compress=zstd,ssd,commit=120,subvol=@/tmp /mnt/tmp
    mount UUID=${ROOTUUID} -o noatime,compress=zstd,ssd,commit=120,subvol=@/usr/local /mnt/usr/local
    mount UUID=${ROOTUUID} -o noatime,ssd,commit=120,subvol=@/var/cache /mnt/var/cache
    mount UUID=${ROOTUUID} -o noatime,ssd,commit=120,subvol=@/var/log,nodatacow /mnt/var/log
    mount UUID=${ROOTUUID} -o noatime,ssd,commit=120,subvol=@/var/spool,nodatacow /mnt/var/spool
    mount UUID=${ROOTUUID} -o noatime,ssd,commit=120,subvol=@/var/tmp,nodatacow /mnt/var/tmp
    mount UUID=${BOOTUUID} /mnt/boot
    

	
echo -ne "done Extract your RootFs inside /mnt"


