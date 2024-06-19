#!/bin/bash

# Gathering system information

# Getting the hostname
HOSTNAME=$(hostname)

# Getting the OS information
OS=$(source /etc/os-release && echo $PRETTY_NAME)

# Getting the system uptime
UPTIME=$(uptime -p)

# Getting the CPU information (model, processor and speed)
CPU_MODEL_PROCESSOR=$(sudo lshw -class processor | grep "product" | sed 's/^[ \t]*//;s/product: //' | head -n 1)

CURRENT_SPEED=$(grep -m 1 'cpu MHz' /proc/cpuinfo | awk '{print $4}')
MAX_SPEED=$(grep -m 1 'cpu MHz' /proc/cpuinfo | awk '{print $4}')

CPU_SPEED="$CURRENT_SPEED MHz / $MAX_SPEED MHz"

# Getting the total installed RAM
RAM=$(free -h | awk '/Mem:/ {print $2}')

# Getting the disk information (make, model, and size)
DISKS=$(sudo lshw -class disk -short | awk '/disk/ {printf "Make: %s Model: %s Size: %s\n", $2, $3, $4}')

# Getting the video card information
VIDEO_CARD=$(sudo lshw -class display -short | grep -i "display" | awk '{$1=""; $2=""; print $0}')

# Gathering network information

# Getting the fully qualified domain name
FQDN=$(hostname -f)

# Getting the host IP address
HOST_ADDRESS=$(hostname -I | awk '{print $1}')

# Getting the gateway IP address
GATEWAY_IP=$(ip r | grep default | awk '{print $3}')

# Getting the DNS server IP address
DNS_SERVER=$(grep "nameserver" /etc/resolv.conf | awk '{print $2}')

# Getting the network interface name
INTERFACE_NAME=$(sudo lshw -class network -short | awk '/network/ {print "Make:", $2, "Model:", $4}')

# Getting the IP address in CIDR format
INTERFACE_IP=$(ip -o -4 addr show | awk '$2 !~ /lo/ {print $4}')

# Gathering system status information

# Getting the currently logged in users
USERS_LOGGED_IN=$(who | awk '{printf "%s,",$1} END {print ""}')

# Getting the available disk space
DISK_SPACE=$(df -h | awk 'NR>1 {printf "%s: %s\n", $6, $4}')

# Getting the total number of running processes
PROCESS_COUNT=$(ps -e | wc -l)

# Getting the load averages
LOAD_AVERAGES=$(uptime | awk -F'load average:' '{ print $2 }' | awk '{printf "%s, ", $1}')

# Getting the memory allocation details
MEMORY_ALLOCATION=$(free -h)

# Getting the list of listening network ports
LISTENING_PORTS=$(ss -tuln | awk 'NR>1 {printf "%s, ", $5}')

# Getting the UFW rules
UFW_RULES=$(sudo ufw status numbered)

# Output the report directly to the terminal
cat <<EOF

System Report generated by $USER, $(date)

System Information
------------------
Hostname: $HOSTNAME
OS: $OS
Uptime: $UPTIME

Hardware Information
--------------------
cpu: $CPU_MODEL_PROCESSOR
Speed: $CPU_SPEED
Ram: $RAM
Disk(s):
$DISKS
Video: $VIDEO_CARD

Network Information
-------------------
FQDN: $FQDN
Host Address: $HOST_ADDRESS
Gateway IP: $GATEWAY_IP
DNS Server: $DNS_SERVER

InterfaceName:
$INTERFACE_NAME
IP Address: $INTERFACE_IP

System Status
-------------
Users Logged In: $USERS_LOGGED_IN
Disk Space:
$DISK_SPACE
Process Count: $PROCESS_COUNT
Load Averages: $LOAD_AVERAGES
Memory Allocation:
$MEMORY_ALLOCATION
Listening Network Ports: $LISTENING_PORTS
UFW Rules:
$UFW_RULES

EOF

