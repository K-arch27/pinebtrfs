#to be run on the device after booting on it
clear
lsblk
read -p "Please enter your Root partition : /dev/" partition2
ROOTUUID=$(blkid -o value -s UUID /dev/$partition2)
clear
pacman -Syyu --noconfirm
pacman -S snapper --noconfirm


umount /.snapshots
rm -r /.snapshots
snapper --no-dbus -c root create-config /
btrfs subvolume delete /.snapshots
mkdir /.snapshots
mount -a
chmod 750 /.snapshots




#Changing The timeline auto-snap
sed -i 's|QGROUP=""|QGROUP="1/0"|' /etc/snapper/configs/root
sed -i 's|NUMBER_LIMIT="50"|NUMBER_LIMIT="10-15"|' /etc/snapper/configs/root
sed -i 's|NUMBER_LIMIT_IMPORTANT="50"|NUMBER_LIMIT_IMPORTANT="5-10"|' /etc/snapper/configs/root
sed -i 's|TIMELINE_LIMIT_HOURLY="10"|TIMELINE_LIMIT_HOURLY="0"|' /etc/snapper/configs/root
sed -i 's|TIMELINE_LIMIT_DAILY="10"|TIMELINE_LIMIT_DAILY="3"|' /etc/snapper/configs/root
sed -i 's|TIMELINE_LIMIT_WEEKLY="0"|TIMELINE_LIMIT_WEEKLY="2"|' /etc/snapper/configs/root
sed -i 's|TIMELINE_LIMIT_MONTHLY="10"|TIMELINE_LIMIT_MONTHLY="2"|' /etc/snapper/configs/root
sed -i 's|TIMELINE_LIMIT_YEARLY="10"|TIMELINE_LIMIT_YEARLY="0"|' /etc/snapper/configs/root



#Enable cleanup
SCRUB=$(systemd-escape --template btrfs-scrub@.timer --path /dev/disk/by-uuid/${ROOTUUID})
systemctl enable --now ${SCRUB}
systemctl enable snapper-timeline.timer
systemctl enable snapper-cleanup.timer

clear

