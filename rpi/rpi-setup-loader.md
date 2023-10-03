# RPi boot loader

Based on [raspberrypi.com](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#updating-the-eeprom-configuration) the following steps update the RPI EEPROM configuration.

## Check boot loader configuration

```sh
vcgencmd bootloader_config
```

## Get a boot loader and extract its configuration

```sh
cd /lib/firmware/raspberrypi/bootloader/beta/
cp pieeprom-2019-11-18.bin new-pieeprom.bin
rpi-eeprom-config new-pieeprom.bin > bootconf.txt
```

## Edit bootconf.txt to change the boot loader configuration

```sh
# BOOT_ORDER bits are read from LSB to MSB
# Boot order below is SD(1), USB-MSD(4), NVME(6), BCM-USB-MSD(5), NETWORK(2) and RESTART(f)
BOOT_ORDER=0xf25641

# Set to 0 to prevent bootloader updates from USB/Network boot
ENABLE_SELF_UPDATE=0
```

## Save the new config to the firmware image

```sh
rpi-eeprom-config --out netboot-pieeprom.bin --config bootconf.txt new-pieeprom.bin
sudo rpi-eeprom-update -d -f ./netboot-pieeprom.bin
```

## Another option is to edit current config and save it

Based on [raspberrypi.com](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#updating-the-eeprom-configuration), the command loads the current EEPROM configuration into a text editor. When the editor is closed, rpi-eeprom-config applies the updated configuration to latest available EEPROM release and uses rpi-eeprom-update to schedule an update when the system is rebooted.

```sh
sudo -E rpi-eeprom-config --edit
sudo reboot
```
