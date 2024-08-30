#!/bin/bash

### initialization

username=$(whoami)
if [ "$EUID" -eq 0 ]
  then echo "do not run as root"
  exit -1
fi

### driver related

# perform a system update & install some needed packages
sudo pacman -Syu base-devel linux-headers --needed

# dispalay card name
lspci -k | grep -A 2 -E "(VGA|3D)"

# enabling multilib
vim /etc/pacman.conf # temporary sollution to enable multilib

# installing drivers and other driver-related packages
sudo pacman -Sy nvidia-open-dkms egl-wayland lib32-nvidia-utils lib32-opencl-nvidia nvidia-settings opencl-nvidia nvidia-utils

# TODO: Setting kernel parameters in bootloader 

# add early loading of nvidia modules, TODO: make sure that is all that is needed
modprobe nvidia NVreg_OpenRmEnableUnsupportedGpus=1
modprobe nvidia_drm modeset=1 
sudo mkinitcpio -P

### sway setup

# privelage managment
sudo pacman -S seatd polkit # (technicaly only one is needed but may improve compatibility?)
sudo usermod -aG seat $username
sudo systemctl enable seatd.service

# seting envaiormental variables
sudo sh -c 'echo "LIBVA_DRIVER_NAME=nvidia" >> /etc/environment '
sudo sh -c 'echo "XDG_SESSION_TYPE=wayland" >> /etc/environment '
sudo sh -c 'echo "GBM_BACKEND=nvidia-drm" >> /etc/environment '
sudo sh -c 'echo "__GLX_VENDOR_LIBRARY_NAME=nvidia" >> /etc/environment '
sudo sh -c 'echo "WLR_NO_HARDWARE_CURSORS=1" >> /etc/environment ' # no visible cursor fix
sudo sh -c 'echo "MOZ_ENABLE_WAYLAND=1" >> /etc/environment ' # firefox flickering fix
# sudo sh -c 'echo "LIBSEAT_BAVKEND=logind" >> /etc/environment ' # error about seatd at sway startup fix
sudo sh -c 'echo "_JAVA_AWT_WM_NONREPARENTING=1" >> /etc/environment ' # fix for some java aplications

# copying default config
mkdir ~/.config/sway
cp /etc/sway/config ~/.config/sway/config


### reboot (end of the script)
reboot now
