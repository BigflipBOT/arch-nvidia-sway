#!/bin/bash

## verify drm kernel module setting
if [[ sudo cat /sys/module/nvidia_drm/parameters/modeset == Y ]]; then
  echo "drm kernel module correctly applied"
else
	echo "error! drm kernel module not correctly applied"
fi

## checking modules being loaded
if [[ mkinitcpio --automods | grep "nvidia" | wc -l -eq 2 ]]; then
  echo "mkinitcpio modules correctly detected"
else
  echo "error, mkinicpio modules might be missing"
fi 

## checking if nvidia-smi output is good 
if [[ nvidia-smi | grep -Po "[-]{2,}" ]]; then
  echo "nvidia smi seems good."
else
  echo "possible error with nvdia-smi (card recognition)"
fi 
nvidia-smi

