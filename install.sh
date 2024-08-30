#!/bin/bash

### initialization

username=$(whoami)
if [ "$EUID" -eq 0 ] ; then 
  echo "do not run as root (sudo)"
  exit -1
fi

### driver related

# perform a system update & install some needed packages
sudo pacman -Syu base-devel linux-headers vim --needed

# dispalay card name
lspci -k | grep -A 2 -E "(VGA|3D)"

# enabling multilib
vim /etc/pacman.conf # temporary solution to enable multilib

# installing drivers and other driver-related packages
sudo pacman -Sy nvidia-open-dkms egl-wayland lib32-nvidia-utils lib32-opencl-nvidia nvidia-settings opencl-nvidia nvidia-utils

# setting kernel parameters in bootloader (here only grub)
sudo cp /etc/default/grub /etc/default/grub.backup #this line makes backup just in case
touch tmp
while IFS="" read -r p || [ -n "$p" ]
do
  if  (printf '%s\n' "$p" | grep -q "GRUB_CMDLINE_LINUX_DEFAULT") ; then
    printf '%s\b nvidia-drm.modeset=1"\n' "$p" >> tmp
  else
    printf '%s\n' "$p" >> tmp
  fi
done < /etc/default/grub.backup
sudo chmod $(stat -c '%a' /etc/default/grub) tmp
sudo chown $(stat -c '%u:%g' /etc/default/grub) tmp
sudo mv tmp /etc/default/grub

# loading modules to initramfs
# TODO

# passing module settings conf file for udev
sudo chown 0:0 ./nvidia_modules.conf
cp ./nvidia_modules.conf /etc/modprobe.d/

# regenerate initramfs
sudo mkinitcpio -P

### wayland setup

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

# copying sway default config
mkdir ~/.config/sway
cp /etc/sway/config ~/.config/sway/config


### reboot (end of the script)
reboot now
