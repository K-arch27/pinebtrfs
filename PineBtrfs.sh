SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $SCRIPT_DIR/config.sh



## Formating Partition and Getting UUID from them

    clear
    echo -ne "Carefull all data on this partition is going to be deleted"
    lsblk
    echo -ne "Carefull all data on this partition is going to be deleted"
    read -p "Please enter your BOOT partition : /dev/" partition1
    mkfs.ext4 -L PINEBOOT /dev/$partition1
    BOOTUUID=$(blkid -o value -s UUID /dev/$partition1)
    clear
    echo -ne "Carefull all data on this partition is going to be deleted"
    lsblk
    echo -ne "Carefull all data on this partition is going to be deleted"
    read -p "Please enter your Root partition : /dev/" partition2
    mkfs.btrfs -L ROOT -m single -f /dev/$partition2
    ROOTUUID=$(blkid -o value -s UUID /dev/$partition2)
    clear


   #Mounting Root on /mnt to create Btrfs Subvolumes
    mount UUID=${ROOTUUID} /mnt


    btrfs subvolume create /mnt/@
	btrfs subvolume create /mnt/@home
    btrfs subvolume create /mnt/@var_log
	btrfs subvolume create /mnt/@var_spool
	btrfs subvolume create /mnt/@var_tmp
	btrfs subvolume create /mnt/@var_cache
	btrfs quota enable /mnt

	#Disable Copy on Write for selected Subvolumes
	chattr +C /mnt/@var_log
	chattr +C /mnt/@var_spool
	chattr +C /mnt/@var_tmp
	chattr +C /mnt/@var_cache

# make directories For subvolume Mount point


	mkdir -p /mnt/@/var/cache
	mkdir /mnt/@/var/log
	mkdir /mnt/@/var/spool
	mkdir /mnt/@/var/tmp
	mkdir /mnt/@/boot
	mkdir /mnt/@/home


# mount Partition and subvolumes
    mount UUID=${ROOTUUID} -o noatime,compress=zstd,ssd,commit=120,subvol=@home /mnt/@/home
    mount UUID=${ROOTUUID} -o noatime,ssd,commit=120,subvol=@var_cache /mnt/@/var/cache
    mount UUID=${ROOTUUID} -o noatime,ssd,commit=120,subvol=@var_log,nodatacow /mnt/@/var/log
    mount UUID=${ROOTUUID} -o noatime,ssd,commit=120,subvol=@var_spool,nodatacow /mnt/@/var/spool
    mount UUID=${ROOTUUID} -o noatime,ssd,commit=120,subvol=@var_tmp,nodatacow /mnt/@/var/tmp
    mount UUID=${BOOTUUID} /mnt/@/boot
    

	
echo -ne "done Extract your RootFs inside /mnt/@/"


