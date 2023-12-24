
# Hardware Information Script (get_hardware_info.sh)

- This script aims to gather comprehensive hardware information of a Linux system, including details about the motherboard, CPU, memory, storage, network interface, audio and GPU devices, operating
system, network configuration, BIOS information, system uptime, temperature readings, and disk health status.
- It requires root privileges to perform hardware scans and install necessary packages on Ubuntu/Debian systems.
- To use the script, run it as follows: `sudo bash get_hardware_info.sh`

The script provides details about:
- System Manufacturer and Product
- Motherboard Information
- CPU, Network Interface, and Display Adapter Information
- USB Controllers
- Memory (RAM) Information
- Disk Storage Information
- Audio and GPU Devices
- Operating System Details
- Network Configuration
- BIOS Information
- System Uptime
- Temperature Readings (requires lm-sensors package)
- Disk Health Status (requires smartmontools package)
