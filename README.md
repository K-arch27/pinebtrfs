# PineBtrfs
## Making Btrfs Root on Pinephone

```
This guide assume you have access to a linux pc with a card reader
(but could be done directly from the phone if you have access to another OS )
Only tested with Arch Phosh but should work with any distro
All Commands Need sudo rights

```


### --- Step 1 ---
Start By flashing/Installing the OS you want in your prefered method onto the SD card

### --- Step 2 ---

mount it and backup the filesystem

>mount /dev/MYDEVICEROOT -o ro /mnt

>mount /dev/MYDEVICEBOOT -o ro /mnt/boot

then zip it in the working directory :

> tar -C /mnt --acls --xattrs -cf root_backup.tar .

### --- Step 3 ---

Unmount it and run fdisk or another partitionning tools to make new partition
We need 1 partition of 512MB for the boot and another one with the space left for the Root

(guide will be updated later on for separate Home partition)

### --- Step 4 ---

We need to format our root as btrfs and our boot as Ext4
and then make our btrfs subvolumes and mountpoints

If you know how go ahead , otherwise a very basic layout can be made using the included PineBtrfs.sh

### --- Step 5 ---

After being done with the layout and mounting everything back (or executing the included script PineBtrfs.sh)
we have to extract our root filesystem back in

> tar -xvf BACKUPLOCATION/root_backup.tar --acls --xattrs --numeric-owner

### --- Step 6 ---

Delete old and Generate New Fstab file

> rm /mnt/etc/fstab

> genfstab -U /mnt >> /mnt/etc/fstab

Verify that everything is right inside it and remove the target subvolume from the root entry

### --- Step 7 ---

Go inside /mnt/boot/
figure out how your distro set up Uboot Environnements
and add the following to it : 

rootfstype=btrfs

```
(for arch we use the boot.txt file and add it to this line : 

setenv bootargs loglevel=4 console=tty0 root=/dev/mmcblk${linux_mmcdev}p${rootpart} console=ttyS2,1500000 rw rootwait quiet bootsplash.bootfile=bootsplash-themes/danctnix/bootsplash


to make : 

setenv bootargs loglevel=4 console=tty0 root=/dev/mmcblk${linux_mmcdev}p${rootpart} console=ttyS2,1500000 rw rootwait rootfstype=btrfs quiet bootsplash.bootfile=bootsplash-themes/danctnix/bootsplash


Then execute 

# mkimage -A arm -O linux -T script -C none -n "U-Boot boot script" -d /mnt/@/boot.txt /mnt/@/boot.scr
```

### --- Step 8 ---

Test it out
Run phone.sh on the phone itself after booting to configure snapper
