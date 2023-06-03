

## Formating Partition and Getting UUID from them

    clear
    lsblk
    echo -ne "-
Carefull all data on this partition is going to be deleted
-"
    read -p "Please enter your BOOT partition : /dev/" partition1
    mkfs.fat -F 32 /dev/$partition1
    BOOTUUID=$(blkid -o value -s UUID /dev/$partition1)
    clear
    lsblk
    echo -ne "-
Carefull all data on this partition is going to be deleted
-"
    read -p "Please enter your Root partition : /dev/" partition2
    mkfs.btrfs -L ROOT -m single -f /dev/$partition2
    ROOTUUID=$(blkid -o value -s UUID /dev/$partition2)
    clear


   #Mounting Root on /install to create Btrfs Subvolumes
    mount UUID=${ROOTUUID} /install


   
    btrfs subvolume create /install/@
	btrfs subvolume create /install/@/.snapshots
	mkdir /install/@/.snapshots/1
	btrfs subvolume create /install/@/.snapshots/1/snapshot
	mkdir /install/@/boot
	btrfs subvolume create /install/@/root
	btrfs subvolume create /install/@/srv
	btrfs subvolume create /install/@/tmp
	mkdir /install/@/usr
	btrfs subvolume create /install/@/usr/local
	mkdir /install/@/var
	btrfs subvolume create /install/@/var/cache
	btrfs subvolume create /install/@/var/log
	btrfs subvolume create /install/@/var/spool
	btrfs subvolume create /install/@/var/tmp
	NOW=$(date +"%Y-%m-%d %H:%M:%S")
	cp info.xml /install/@/.snapshots/1/info.xml
	sed -i "s|2022-01-01 00:00:00|${NOW}|" /install/@/.snapshots/1/info.xml
  	btrfs subvolume set-default $(btrfs subvolume list /install | grep "@/.snapshots/1/snapshot" | grep -oP '(?<=ID )[0-9]+') /install
	btrfs quota enable /install
	chattr +C /install/@/var/cache
	chattr +C /install/@/var/log
	chattr +C /install/@/var/spool
	chattr +C /install/@/var/tmp

# unmount root to remount with subvolume
    umount /install

# mount @ subvolume
    mount UUID=${ROOTUUID} -o compress=zstd /install

# make directories home, .snapshots, var, tmp

	mkdir /install/.snapshots
	mkdir /install/root
	mkdir /install/srv
	mkdir /install/tmp
	mkdir -p /install/usr/local
	mkdir -p /install/var/cache
	mkdir /install/var/log
	mkdir /install/var/spool
	mkdir /install/var/tmp
	mkdir /install/boot
	mkdir /install/home


# mount subvolumes and partition

    mount UUID=${ROOTUUID} -o noatime,compress=zstd,ssd,commit=120,subvol=@/.snapshots /install/.snapshots
    mount UUID=${ROOTUUID} -o noatime,compress=zstd,ssd,commit=120,subvol=@/root /install/root
    mount UUID=${ROOTUUID} -o noatime,compress=zstd,ssd,commit=120,subvol=@/srv /install/srv
    mount UUID=${ROOTUUID} -o noatime,compress=zstd,ssd,commit=120,subvol=@/tmp /install/tmp
    mount UUID=${ROOTUUID} -o noatime,compress=zstd,ssd,commit=120,subvol=@/usr/local /install/usr/local
    mount UUID=${ROOTUUID} -o noatime,ssd,commit=120,subvol=@/var/cache /install/var/cache
    mount UUID=${ROOTUUID} -o noatime,ssd,commit=120,subvol=@/var/log,nodatacow /install/var/log
    mount UUID=${ROOTUUID} -o noatime,ssd,commit=120,subvol=@/var/spool,nodatacow /install/var/spool
    mount UUID=${ROOTUUID} -o noatime,ssd,commit=120,subvol=@/var/tmp,nodatacow /install/var/tmp
    mount UUID=${BOOTUUID} /install/boot
    

	
echo -ne "Done 
Mount your Home partition in /install/home if you have one now and Extract your RootBackup inside /install"


