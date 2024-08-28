#!/bin/bash

### initialization

# seting some variables
username=$(whoami)


### driver related

# perform a system update
sudo pacman -Syu

# dispalay card name
lspci -k | grep -A 2 -E "(VGA|3D)"

# install basic tools needed to proceed
# sudo pacman -S git vim
vim /etc/pacman.conf # temporary sollution to enablim multilib
sudo pacman -S nvidia-open-dkms linux-headers nvidia-utils lib32-nvidia-utils # TODO: add enabling multilib before that

# TODO: Setting kernel parameters in bootloader (maybe not needed?)

# add early loading of nvidia modules, TODO: make sure that is all that is needed
modprobe nvidia NVreg_OpenRmEnableUnsupportedGpus=1
modprobe nvidia_drm modeset=1 # not sure if this is needed while installing nvidia-open? maybe check that later

# check for errors
mkinitcpio
mkinitcpio --automods | grep "nvidia" | wc -l


### sway setup

# privelage managment
sudo pacman -S seatd polkit # (technicaly only one is needed but may improve compatibility?)
sudo usermod -aG seat $username

# seting envaiormental variables
sudo sh -c 'echo "LIBVA_DRIVER_NAME=nvidia" >> /etc/environment '
sudo sh -c 'echo "XDG_SESSION_TYPE=wayland" >> /etc/environment '
sudo sh -c 'echo "GBM_BACKEND=nvidia-drm" >> /etc/environment '
sudo sh -c 'echo "__GLX_VENDOR_LIBRARY_NAME=nvidia" >> /etc/environment '
sudo sh -c 'echo "WLR_NO_HARDWARE_CURSORS=1" >> /etc/environment '
sudo sh -c 'echo "MOZ_ENABLE_WAYLAND=1" >> /etc/environment '

# reboot (end of the script)
reboot now
