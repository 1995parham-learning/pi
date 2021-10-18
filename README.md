# pi

## Intrdoduction

I have an old (version 3) raspberry pi from the era in which I worked on IoT. here I tried to configure it with Arch (aarch64).
also I bought a new raspberry pi (verion 4) and I want to install Arch (armv7).

## Arch on ARM 💪

1. start `fdisk` to partition the sd card
2. at the `fdisk` prompt, delete old partitions and create a new one:
   1. Type o. This will clear out any partitions on the drive.
   2. Type p to list partitions. There should be no partitions left.
   3. Type n, then p for primary, 1 for the first partition on the drive, press ENTER to accept the default first sector, then type +200M for the last sector.
   4. Type t, then c to set the first partition to type W95 FAT32 (LBA).
   5. Type n, then p for primary, 2 for the second partition on the drive, and then press ENTER twice to accept the default first and last sector.
   6. Write the partition table and exit by typing w.
3. `sudo pacman -Syu dosfstools`
4. Create and mount the ext4 filesystem:

   ```sh
   mkfs.ext4 /dev/sdX2
   mount /dev/sdX2 /mnt
   ```

5. create and mount the FAT filesystem:

   ```sh
   mkfs.vfat /dev/sdX1
   mkdir /mnt/boot
   mount /dev/sdX1 /mnt/boot
   ```

6. download and extract the root filesystem (as root, not via sudo):

   ```sh
   # aarch64 (rpi3)
   aria2c http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-aarch64-latest.tar.gz
   tar xvfz ArchLinuxARM-rpi-aarch64-latest.tar.gz -C /mnt
   ```

   ```sh
   # armv7 (rpi4)
   aria2c http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-4-latest.tar.gz
   tar xvfz ArchLinuxARM-rpi-4-latest.tar.gz -C /mnt
   ```

7. insert the SD card into the Raspberry Pi, connect ethernet, and apply 5V power.

## Initiation

1. use the serial console or SSH to the IP address given to the board by your router.
   1. login as the default user `alarm` with the password `alarm`.
   2. the default `root` password is `root`.
2. initialize the pacman keyring and populate the Arch Linux ARM package signing keys:

   ```sh
   su
   pacman-key --init
   pacman-key --populate archlinuxarm
   ```

## Create Me 🐼

```sh
su
pacman -Syu
pacman -Syu base-devel

useradd -m parham
groupadd sudo
usermod -a -G sudo parham
passwd parham

# allow the sudo group to be sudoers
visudo
```

## Network 🖧

we use [systemd-networkd](https://wiki.archlinux.org/title/Systemd-networkd) for networking:

```
[Match]
Name=eth0

[Network]
Address=192.168.73.98/24
Gateway=192.168.73.254
DNS=192.168.73.254
DNS=8.8.8.8
```

save the above configuration in `/etc/systemd/network/20-wired.network`. then enable it with the following command:

```sh
sudo systemctl restart systemd-networkd
```

if you want to have the wifi, you can use `wifi-menu` to generate `netctl` profile and then configurate it.

```sh
sudo wifi-menu

sudo systemctl stop systemd-networkd.service
sudo systemctl stop systemd-resolved.service
```

```
Description='Automatically generated profile by wifi-menu'
Interface=wlan0
Connection=wireless
Security=wpa
ESSID=Parham-Main
IP=static
Key=***
Address=('192.168.73.96/24')
Gateway='192.168.73.254'
DNS=('192.168.73.254' '8.8.8.8')
DNSSearch='parham.home'
```

## Ready for Ansible 🚀

First of all copy the ssh public key into the host and then install the following packages after that you are ready for ansible.

```sh
ssh-copy-id
sudo pacman -Syu python inetutils
```
