# PineBtrfs
## Btrfs Root on Pinephone Pro


### Arch image ready to be flashed and use can be found in Release (based on danct12 Arch)

Or you can Generate yourself an up-to-date image with this : https://github.com/K-arch27/arch-pine64-build-btrfs



## --- Doing it yourself for Another distro ---

```
This guide assume you have access to a linux pc with a card reader
(but could be done directly from the phone if you have access to another OS )
Only tested with Arch but should work with any distro
All Commands Need sudo rights

```

### --- Step 1 ---
Start By flashing/Installing the OS you want with your prefered method onto the SD card
and do the initial setup on the phone (good time to update it too) and install the relevant btrfs package for your distribution and add the btrfs module to the initramfs

remove fsck hook in /etc/mkinitcpio.conf if any
and regenerate the initramfs

### --- Step 2 ---
Get the SD card in your computer ( or boot another system on your phone )

mount it and backup the filesystem

>mount /dev/MYDEVICEROOT -o ro /mnt

>mount /dev/MYDEVICEBOOT -o ro /mnt/boot

then zip it in the working directory :

> tar -C /mnt --acls --xattrs -cf root_backup.tar .

### --- Step 3 ---

Unmount it and run fdisk or another partitionning tools to make new partition
We need 1 partition of atleast 320MB for the boot and another one with the space left for the Root or separate it with a home partition as you wish


### --- Step 4 ---

We need to format our root as btrfs, our boot as Ext4 and home as what you prefer
and then make our btrfs subvolumes and mountpoints

If you know how go ahead , otherwise a basic layout can be made using the included PineBtrfs.sh script wich is compatible with snapper and rollback

### --- Step 5 ---

After being done with the layout and mounting everything back (or executing the included script PineBtrfs.sh)
we have to extract our root filesystem back in the /mnt directory

> cd /mnt
> tar -xvf BACKUPLOCATION/root_backup.tar --acls --xattrs --numeric-owner

### --- Step 6 ---

Generate New Fstab file

> genfstab -U /mnt > /mnt/etc/fstab

Verify that everything is right inside it 

If you use the Pinebtrfs.sh script remove the target subvolume from the root entry 
so the line look like that :


```
UUID=YOURUUID	/         	btrfs     	rw,relatime,compress=zstd:3,space_cache=v2	0 0

```
so that we are able to boot on a different snapshots if we rollback

### --- Step 7 ---

Go inside /mnt/boot/
figure out how your distro set up Uboot Environnements (you'll need u-boot-tools)
and add the following to it : 

rootfstype=btrfs


(for arch we use the boot.txt file and modify this line : 
```
setenv bootargs loglevel=4 console=tty0 root=/dev/mmcblk${linux_mmcdev}p${rootpart} console=ttyS2,1500000 rw rootwait quiet bootsplash.bootfile=bootsplash-themes/danctnix/bootsplash
```

to make : 
```
setenv bootargs loglevel=4 console=tty0 root=/dev/mmcblk${linux_mmcdev}p${rootpart} console=ttyS2,1500000 rw rootfstype=btrfs rootwait quiet bootsplash.bootfile=bootsplash-themes/danctnix/bootsplash
```

Then execute 

> mkimage -A arm -O linux -T script -C none -n "U-Boot boot script" -d /mnt/boot.txt /mnt/boot.scr


### --- Step 8 ---

Test it out

You can now run phone.sh on the phone itself after booting to automatically install and configure snapper for you 
