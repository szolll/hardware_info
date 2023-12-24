#!/bin/bash

# License: MIT
#
# Purpose: To gather comprehensive hardware information of a Linux system.
#
# Usage: Run this script as root to get detailed information about various hardware components.
#        It automatically checks for and installs missing dependencies on Ubuntu/Debian systems.
#        Usage command: sudo bash get_hardware_info.sh
#
# The script provides details about:
#   - System Manufacturer and Product
#   - Motherboard Information
#   - CPU, Network Interface, and Display Adapter Information
#   - USB Controllers
#   - Memory (RAM) Information
#   - Disk Storage Information
#   - Audio and GPU Devices
#   - Operating System Details
#   - Network Configuration
#   - BIOS Information
#   - System Uptime
#   - Temperature Readings (requires lm-sensors package)
#   - Disk Health Status (requires smartmontools package)
#
# Note: This script needs to be run with root privileges to perform hardware scans and install necessary packages.
#       It's designed for Ubuntu/Debian environments. While it may work on other distributions, 
#       automatic installation of missing commands is tailored to apt package manager.
#
# Tested on: Ubuntu-22.04
#
# Author: [Daniel Sol]
# Date: [24-DEC-2024]
#
# Disclaimer: Run this script at your own risk. The author is not responsible for any potential system changes or damage.


# Check if running as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root."
   exit 1
fi

# Function to check and install missing commands
ensure_command() {
    command -v "$1" &>/dev/null && return

    echo "'$1' command not found. Attempting to install..."
    apt-get update && apt-get install -y "$2"

    if command -v "$1" &>/dev/null; then
        echo "'$1' successfully installed."
    else
        echo "Failed to install '$1'. Some features may not be available."
    fi
}

printf "Gathering hardware information...\n"
printf "================================== \n"

# Ensure required commands are installed
ensure_command dmidecode dmidecode
ensure_command lshw lshw
ensure_command lsusb usbutils
ensure_command lspci pciutils
ensure_command lsblk util-linux
ensure_command ip iproute2
ensure_command sensors lm-sensors
ensure_command smartctl smartmontools

# Function to extract and print hardware info if available
extract_info() {
    if lshw -class "$1" &>/dev/null; then
        printf "\n%s:\n" "$1"
        lshw -class "$1" 2>/dev/null | grep -E 'product:|vendor:|version:' | sed 's/^[ \t]*//' | awk 'ORS=NR%2?"; ":"\n"'
    else
        printf "\n%s information not available.\n" "$1"
    fi
}

# System Manufacturer and Product Name
printf "\nSystem Manufacturer and Product:\n"
sudo dmidecode -t system | grep -E 'Manufacturer:|Product Name:' | sed 's/^[ \t]*//'

# Motherboard Information
printf "\nMotherboard Information:\n"
sudo dmidecode -t baseboard | grep -E 'Manufacturer:|Product Name:|Version:' | sed 's/^[ \t]*//'

# CPU Information
extract_info processor

# Network Interface Information
extract_info network

# Display Adapter Information
extract_info display

# USB Controllers
printf "\nUSB Controllers:\n"
lsusb | cut -d' ' -f7- | sed 's/\[.*\]//' | uniq

# Memory Information
printf "\nMemory Information:\n"
sudo dmidecode -t memory | grep -E 'Size:|Type:|Speed:' | sed 's/^[ \t]*//'

# Disk Storage Information
printf "\nDisk Storage Information:\n"
lsblk -d -o NAME,SIZE,MODEL | awk 'NR>1'

# Audio Devices
printf "\nAudio Devices:\n"
lspci | grep -i audio

# GPU Information
printf "\nGPU Information:\n"
lspci | grep -i vga

# Operating System Details
printf "\nOperating System Details:\n"
uname -a

# Network Configuration
printf "\nNetwork Configuration:\n"
ip addr show | grep -w inet

# BIOS Information
printf "\nBIOS Information:\n"
sudo dmidecode -t bios | grep -E 'Vendor:|Version:|Release Date:'

# System Uptime
printf "\nSystem Uptime:\n"
uptime -p

# Temperature Sensors (requires lm-sensors package)
printf "\nTemperature Readings:\n"
sensors

# Disk Health Status (requires smartmontools package)
printf "\nDisk Health Status:\n"
for disk in $(lsblk -dn -o NAME,TYPE | awk '$2 == "disk" {print $1}'); do
    if [ -b "/dev/$disk" ]; then
        printf "Checking /dev/%s:\n" "$disk"
        # Check if the device supports SMART
        if sudo smartctl -i /dev/"$disk" | grep -q 'SMART support is: Available'; then
            sudo smartctl -H /dev/"$disk"
        else
            printf "SMART not supported or not available for /dev/%s\n" "$disk"
        fi
    fi
done

printf " ================================== \n"
printf "Hardware information gathered successfully!\n"
