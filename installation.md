# Installation

Sources:

- <https://wiki.archlinux.org/index.php/installation_guide>
- <https://wiki.archlinux.org/index.php/USB_flash_installation_media>
- <https://wiki.archlinux.org/index.php/Dm-crypt/Drive_preparation>
- <https://wiki.archlinux.org/index.php/Dm-crypt/Specialties#Encrypted_system_using_a_detached_LUKS_header>

## Create installation USB stick

> **Important** Double check device name to not overwrite wrong disk!

1. [Download Arch linux](https://www.archlinux.org/download/)
2. [Download PGP checksum](https://www.archlinux.org/download/)
3. Verify PGP signature `pacman-key -v ~/Downloads/archlinux-2019.10.01-x86_64.iso.sig`
4. Create USB stick `sudo dd bs=4M if="$HOME/Downloads/archlinux-2019.10.01-x86_64.iso" of=/dev/sdb status=progress oflag=sync`

## Configure BIOS

Ensure sensible settings in all BIOS settings, especially around security options (e.g. set passwords).

> **TODO** Describe all desired settings in detail.

## Prepare data and boot disks

The data and swap partitions are going to be installed on the main drive of the
Laptop. The UEFI partition, LUKS header, and /boot partition are put on a
separate USB stick or SD card.

Details can be found here <https://wiki.archlinux.org/index.php/Dm-crypt/Drive_preparation>.

1. Select target `sudo fdisk -l`
2. Ensure device is not mounted `umount /dev/sdb1`
3. Create temporary encryption container `sudo cryptsetup open --type plain -d /dev/urandom /dev/sdb to_be_wiped`
4. Whipe the container with zeros `dd if=/dev/zero of=/dev/mapper/to_be_wiped status=progress`
5. Close the container `sudo cryptsetup close to_be_wiped`

## Prepare SSH terminal on new computer

1. Boot into Arch installation medium
2. Connect to wifi `wifi-menu`
3. Verify internet access `ping -c1 archlinux.org`
4. Update the system clock `timedatectl set-ntp true`
5. Update password `passwd`
6. Start SSH daemon `systemctl start sshd.service`
7. Look up hostname `hostname`
8. Connect from working station to new laptop `ssh root@archiso`

## Prepare boot drive

```console
# delete any existing partition table
gdisk /dev/sdb

# create three partitions on USB dongle
cgdisk /dev/sdb

# Size: 512M, Hex Code: ef00, Name: ESP
# Size: 512M, Hex Code: default (8300), Name: Boot
# Size: default (remaining space), Hex Code: default (8300), Name: Storage
#
# Select "Write" and "Quit" when done

# format ESP
mkfs.fat -F32 /dev/sdb1

# create encrypted container for /boot
cryptsetup luksFormat /dev/sdb2 --type luks1
cryptsetup open /dev/sdb2 cryptboot

# create and mount boot filesystem
mkfs.ext4 /dev/mapper/cryptboot
mount /dev/mapper/cryptboot /mnt

# optional: format storage partition
mkfs.fat -F32 /dev/sdb3
```

## Prepare system drive

The system drive will host the swap and root partition. Ext4 is used for the
root partition. The swap partition size should be at least as large as the
available memory. The LUKS header will be mounted separately and put on the USB
stick later on.

Additionally, a binary keyfile for the cryptroot device is added and stored on
`/boot` inside the cryptboot device. This removes the need to type two
passphrases during boot. As the cryptboot device is normally closed and only
open during boot, this should be secure.

```console
# create and open encrypted container with detached LUKS header
truncate -s 16M /mnt/luksheader
cryptsetup luksFormat /dev/nvme0n1 --type luks1 --header /mnt/luksheader
cryptsetup open --type luks1 --header /mnt/luksheader /dev/nvme0n1 cryptroot

# create binary keyfile and store it on cryptboot as well
dd bs=512 count=4 if=/dev/random of=/mnt/lukskey iflag=fullblock
chmod 600 /mnt/lukskey
cryptsetup --header /mnt/luksheader luksAddKey /dev/nvme0n1 /mnt/lukskey

# verify container was opened and mapped (/dev/mapper/cryptboot, /dev/mapper/cryptroot)
fdisk -l

# unmount boot partition
umount /mnt

# create volume group
pvcreate /dev/mapper/cryptroot
vgcreate system /dev/mapper/cryptroot

# create logical volumes
lvcreate -L 16G system -n swap
lvcreate -l 100%FREE system -n root

# format logical volumes
mkswap /dev/mapper/system-swap
swapon -d /dev/mapper/system-swap
mkfs.ext4 /dev/mapper/system-root
mount /dev/mapper/system-root /mnt

# mount /boot and ESP into root
mkdir /mnt/boot
mount /dev/mapper/cryptboot /mnt/boot
mkdir /mnt/boot/efi
mount /dev/sdb1 /mnt/boot/efi
```

## Arch Linux installation

### Initialization

1. Change mirror package server if desired `vim /etc/pacman.d/mirrorlist`
2. Install base images `pacstrap /mnt base linux linux-firmware lvm2 efibootmgr grub-efi-x86_64 intel-ucode mkinitcpio vim netctl dhclient dialog wpa_supplicant ifplugd`
3. Generate fstab `genfstab -Up /mnt >> /mnt/etc/fstab`
4. Change fstab entries of /boot and /boot/efi to use "noauto" flag `vim /mnt/etc/fstab`
5. Add /tmp ramdisk `vim /mnt/etc/fstab`

   ```text
   # tmpfs
   tmpfs     /tmp         tmpfs  defaults,noatime,mode=1777  0 0
   ```

6. Add cryptboot to crypttab `vim /mnt/etc/crypttab`

    The disk `<identifier>` can be found with `blkid /dev/sdb2`.

   ```text
   cryptboot    UUID=<identifier>    none    noauto,luks
   ```

7. Change root `arch-chroot /mnt`

### Ramdisk configuration

1. Make copies of 'encrypt' hook files

   ```console
   cp /lib/initcpio/hooks/encrypt /lib/initcpio/hooks/customencrypt
   cp /usr/lib/initcpio/install/encrypt /usr/lib/initcpio/install/customencrypt
   ```

2. Add detached LUKS header support to 'customencrypt' hook `vim /lib/initcpio/hooks/customencrypt`

   ```text
   # make the following modifications:
   # ...
   #    warn_deprecated() {
   #         echo "The syntax 'root=${root}' where '${root}' is an encrypted volume is deprecated"
   #         echo "Use 'cryptdevice=${root}:root root=/dev/mapper/root' instead."
   #     }
   #
   #>>>  local headerFlag=false
   #     for cryptopt in ${cryptoptions//,/ }; do
   #         case ${cryptopt} in
   #             allow-discards)
   #                 cryptargs="${cryptargs} --allow-discards"
   #                 ;;
   #>>>          header)
   #>>>              cryptargs="${cryptargs} --header /boot/luksheader"
   #>>>              headerFlag=true
   #>>>              ;;
   #             *)
   #                 echo "Encryption option '${cryptopt}' not known, ignoring." >&2
   #                 ;;
   #         esac
   #     done
   #
   #     if resolved=$(resolve_device "${cryptdev}" ${rootdelay}); then
   #>>>      if $headerFlag || cryptsetup isLuks ${resolved} >/dev/null 2>&1; then
   #             [ ${DEPRECATED_CRYPT} -eq 1 ] && warn_deprecated
   #             dopassphrase=1
   ```

3. Add modules, binaries, files and hooks to config `vim /etc/mkinitcpio.conf`

   ```text
   ...
   MODULES=(i915 loop)
   ...
   FILES=(/boot/luksheader /boot/lukskey)
   ...
   HOOKS=(base udev autodetect keyboard keymap modconf block customencrypt lvm2 filesystems fsck)
   ```

4. Generate initial ramdisk `mkinitcpio -p linux`

### Bootloader Installation

1. Get NVMe device identifier (remember as `$YourDiskId`) `ls -l /dev/disk/by-id | grep nvme0n1`
2. Change Grub defaults `vim /etc/default/grub`

   ```text
   GRUB_CMDLINE_LINUX="cryptdevice=/dev/disk/by-id/$YourDiskId:cryptroot:allow-discards,header cryptkey=rootfs:/boot/lukskey"
   GRUB_PRELOAD_MODULES="part_gpt part_msdos lvm"
   GRUB_ENABLE_CRYPTODISK=y
   ```

3. Configure and install Grub

   ```console
   mkdir -p /boot/grub
   grub-mkconfig -o /boot/grub/grub.cfg
   grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="grub"
   ```

### System Configuration

- Set time zone and configure hardware clock

  ```console
  ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
  hwclock --systohc --utc
  ```

- Set locale

  ```console
  vim /etc/locale.gen # Uncomment desired ones
  locale-gen
  echo LANGUAGE=en_US >> /etc/locale.conf
  echo LANG=en_US.UTF-8 >> /etc/locale.conf
  ```

- Set hostname `hostnamectl set-hostname your-hostname`

- Add user

  ```console
  useradd -m -g users -G wheel,storage,power -s /bin/bash your-username
  passwd your-username
  passwd -l root
  ```

- Install and enable sudo

  ```console
  pacman -S sudo
  EDITOR=vim visudo # uncomment "%wheel ALL=(ALL) ALL"
  ```

### Reboot

```console
exit
umount -R /mnt
swapoff -a
reboot
```

## Secure Boot

1. Enter a strong Administrator Password in BIOS Setup
2. Perform 'Reset to Setup Mode' in BIOS Setup
3. Install cryptboot

   ```console
   # install git client
   sudo pacman -S base-devel git
   # clone, build and install cryptboot
   git clone https://github.com/xmikos/cryptboot
   cd cryptboot
   makepkg -si --skipchecksums
   ```

4. Mount boot partition, and create & enroll UEFI keys

   ```console
   sudo cryptboot mount
   sudo cryptboot-efikeys create
   sudo cryptboot-efikeys enroll
   sudo cryptboot update-grub
   sudo cryptboot umount
   sudo shutdown -P now
   ```

5. Enable Secure Boot in BIOS Setup

## Backup

In order to recover from a cryptboot disk failure, the following steps take a
backup of the ESP and Boot partition. Store these on cloud drive and rebuild
another stick in case of issues.

```console
# backup ESP
dd if=/dev/sda1 conv=sync,noerror bs=64K | gzip -c > esp-backup.img.gz
# backup Boot
dd if=/dev/sda2 conv=sync,noerror bs=64K | gzip -c > boot-backup.img.gz
```

Partition a new stick as described above, and restore from the images:

```console
# restore ESP
gunzip -c esp-backup.img.gz | sudo dd of=/dev/sdb1
# restore Boot
gunzip -c boot-backup.img.gz | sudo dd of=/dev/sdb2
```

Finally, change the UUIDs of `/dev/sdb1` and/or `/dev/sdb2` in `/etc/fstab` and
`/etc/crypttab` according to the output of `ls -la /dev/disk/by-uuid`.

<https://wiki.archlinux.org/index.php/Dd#Create_disk_image>

## Misc

### Security considerations

AES is generally considered secure, has hardware acceleration and is the most
widely used encryption standard next two twofish and serpent, so it's the
cryptsetup defaults are followed.

### Remount

```console
# open encrypted devices
cryptsetup open /dev/sda2 cryptboot
mount /dev/mapper/cryptboot /mnt
cryptsetup open --type luks1 --header /mnt/luksheader /dev/nvme0n1 cryptroot
umount /mnt

# wait for /dev/mapper/system-root to appear
mount /dev/mapper/system-root /mnt
mount /dev/mapper/cryptboot /mnt/boot
mount /dev/sda1 /mnt/boot/

# use system installation
arch-chroot /mnt
```
