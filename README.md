# Pi

## Introduction

I have an old (version 3) raspberry pi from the era in which I worked on IoT.
Here I tried to configure it with ArchLinux (aarch64 architecture).
Also I bought a new raspberry pi (version 4) and I want to install ArchLinux (armv7 architecture).

## Arch on ARM 💪

1. Start `fdisk` to partition the SD card
2. At the `fdisk` prompt, delete old partitions and create new ones:
   1. Type o. This will clear out any partitions on the drive.
   2. Type p to list partitions. There should be no partitions left.
   3. Type n, then p for primary, 1 for the first partition on the drive, press ENTER to accept the default first sector, then type +200M for the last sector.
   4. Type t, then c to set the first partition to type W95 FAT32 (LBA).
   5. Type n, then p for primary, 2 for the second partition on the drive, and then press ENTER twice to accept the default first and last sector.
   6. Write the partition table and exit by typing w.
3. `sudo pacman -Syu dosfstools` to use FAT filesystem.
4. Create and mount the ext4 filesystem:

   ```bash
   mkfs.ext4 /dev/sdX2
   mount /dev/sdX2 /mnt
   ```

5. create and mount the FAT filesystem:

   ```bash
   mkfs.vfat /dev/sdX1
   mkdir /mnt/boot
   mount /dev/sdX1 /mnt/boot
   ```

6. Download (<https://archlinuxarm.org>) and extract the root file system (as root, not via sudo):

   ```bash
   # aarch64 (rpi3)
   aria2c http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-aarch64-latest.tar.gz
   tar xvfz ArchLinuxARM-rpi-aarch64-latest.tar.gz -C /mnt
   ```

   ```bash
   # armv7 (rpi4)
   aria2c http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-4-latest.tar.gz
   tar xvfz ArchLinuxARM-rpi-4-latest.tar.gz -C /mnt
   ```

7. Insert the SD card into the Raspberry Pi, connect Ethernet cable, and apply 5V power.
8. With models that has built-in Bluetooth support you need to apply following layout and kernel parameters to make the serial console work.

   _config.txt_:

   ```
   dtoverlay=miniuart-bt
   ```

   _cmdline.txt_:

   ```
   console=tty1 console=ttyAMA0,115200
   ```

## Initiation

1. Use the serial console or SSH to the IP address given to the board by your router.
   1. Login as the default user `alarm` with the password `alarm`.
   2. The default `root` password is `root`.
2. Initialize the pacman keyring and populate the Arch Linux ARM package signing keys:

   ```bash
   su
   pacman-key --init
   pacman-key --populate archlinuxarm


   pacman -Syu
   pacman -Syu base-devel
   ```

## Create Me 🐼

```bash
su

useradd -m parham
groupadd sudo
usermod -a -G sudo parham
passwd parham

# allow the sudo group's users to be sudoers
visudo
```

## Network 🖧

we use [systemd-networkd](https://wiki.archlinux.org/title/Systemd-networkd) for networking:

```systemd
[Match]
Name=eth0

[Network]
Address=192.168.73.98/24
Gateway=192.168.73.254
DNS=192.168.73.254
DNS=8.8.8.8
```

Save the above configuration in `/etc/systemd/network/20-wired.network`. Then enable it with the following command:

```bash
sudo systemctl restart systemd-networkd
```

If you want to have the wifi, you can use `wifi-menu` to generate `netctl` profile and then configurate it.

```bash
sudo wifi-menu

sudo systemctl stop systemd-networkd.service
sudo systemctl stop systemd-resolved.service
```

```systemd
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

First copy the ssh public key into the host and then install the following packages, after that you are ready for Ansible.

```bash
ssh-copy-id
```

```bash
sudo pacman -Syu python inetutils
```

## How to use AUR

In order to use AUR on ARM Arch, we can clone it and make it manually. For example:

```bash
git clone https://aur.archlinux.org/blocky
cd blocky
make -si
```

## LoRa Modules

- [SX1268 433M LoRa HAT](https://www.waveshare.com/wiki/SX1268_433M_LoRa_HAT)
- [SX1302 868M LoRaWAN Gateway](https://www.waveshare.com/wiki/SX1302_868M_LoRaWAN_Gateway)
