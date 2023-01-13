# Pi 🫐

## Introduction

I have an old (version 3) Raspberry Pi from the era in which I worked on IoT.
Here I tried to configure it with ArchLinux (aarch64 architecture).
Also I bought a new raspberry pi (version 4) and I want to install ArchLinux (armv7 architecture).

## Information

### BCM2835

The BCM2835 is the Broadcom chip used in the Raspberry Pi Model A, B, B+, the Compute Module, and the Raspberry Pi Zero.
[Datasheet](https://datasheets.raspberrypi.org/bcm2835/bcm2835-peripherals.pdf)

### BCM2836

The Broadcom chip used in the Raspberry Pi 2 Model B. The underlying architecture in BCM2836 is identical to BCM2835.
The only significant difference is the removal of the ARM1176JZF-S processor and replacement with a quad-core Cortex-A7 cluster.

### BCM2837

This is the Broadcom chip used in the Raspberry Pi 3, and in later models of the Raspberry Pi 2.
The underlying architecture of the BCM2837 is identical to the BCM2836.
The only significant difference is the replacement of the ARMv7 quad core cluster with a quad-core ARM Cortex A53 (ARMv8) cluster.
The ARM cores run at 1.2GHz, making the device about 50% faster than the Raspberry Pi 2. The VideoCore IV runs at 400MHz.

### BCM2837B0

This is the Broadcom chip used in the Raspberry Pi 3B+ and 3A+. The underlying architecture of the BCM2837B0 is identical to the BCM2837 chip used in other versions of the Pi.
The ARM core hardware is the same, only the frequency is rated higher.
The ARM cores are capable of running at up to 1.4GHz, making the 3B+/3A+ about 17% faster than the original Raspberry Pi 3.
The VideoCore IV runs at 400MHz.
The ARM core is 64-bit, while the VideoCore IV is 32-bit.
The BCM2837B0 chip is packaged slightly differently to the BCM2837, and most notably includes a heat spreader for better thermals.
This allows higher clock frequencies, and more accurate monitoring and control of the chip’s temperature.

### BCM2711

This is the Broadcom chip used in the Raspberry Pi 4 Model B. The architecture of the BCM2711 is a considerable upgrade on that used by the SoCs in earlier Raspberry Pi models.
It continues the quad-core CPU design of the BCM2837, but uses the more powerful ARM A72 core.
It has a greatly improved GPU feature set with much faster input/output, due to the incorporation of a PCIe link that connects the USB 2 and USB 3 ports, and a natively attached Ethernet controller.
It is also capable of addressing more memory than the SoCs used before.

The ARM cores are capable of running at up to 1.5 GHz, making the Pi 4 about 50% faster than the Raspberry Pi 3B+.
The new VideoCore VI 3D unit now runs at up to 500 MHz.
The ARM cores are 64-bit, and while the VideoCore is 32-bit, there is a new Memory Management Unit, which means it can access more memory than previous versions.

The BCM2711 chip continues to use the heat spreading technology started with the BCM2837B0, which provides better thermal management.

- Processor: Quad-core Cortex-A72 (ARM v8) 64-bit SoC @ 1.5 GHz.
- Memory: Accesses up to 8GB LPDDR4-2400 SDRAM (depending on model)
- Caches: 32 KB data + 48 KB instruction L1 cache per core. 1MB L2 cache.
- Multimedia: H.265 (4Kp60 decode); H.264 (1080p60 decode, 1080p30 encode); OpenGL ES, 3.0 graphics
- I/O: PCIe bus, onboard Ethernet port, 2 × DSI ports (only one exposed on Raspberry Pi 4B), 2 × CSI ports (only one exposed on Raspberry Pi 4B), up to 6 × I2C, up to 6 × UART (muxed with I2C), up to 6 × SPI (only five exposed on Raspberry Pi 4B), dual HDMI video output, composite video output.

## config.txt

The Raspberry Pi uses a configuration file instead of the BIOS you would expect to find on a conventional PC.
The system configuration parameters, which would traditionally be edited and stored using a BIOS, are stored instead in an optional text file named config.txt.

[read more](https://www.raspberrypi.com/documentation/computers/config_txt.html#what-is-config-txt)

## in Go

[Raspberry Pi GPIO library for golang](https://github.com/stianeikeland/go-rpio)

## Pioneer 600

Raspberry Pi Expansion Board, Miscellaneous Components, All-in-One
[read more](https://www.waveshare.com/wiki/Pioneer600)

- CP2102: USB To UART Bridge
- DS3231: Extremely Accurate I2C-IntegratedRTC/TCXO/Crystal
- BMP180: Digital pressure sensor
- SSD1306: OEL Display Module
- PCF8591: 8-bit A/D and D/A converter
- PCF8574: Remote 8-bit I/O expander for I2C-bus

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

If you want to have the Wi-Fi, you can use `wifi-menu` to generate `netctl` profile and then configure it.

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
