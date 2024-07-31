#!/bin/bash

# Initializing variables
VERBOSE=false

# Checking for verbose mode
for arg in "$@"; do
    if [ "$arg" == "-verbose" ]; then
        VERBOSE=true
    fi
done

# Determining verbose option
if [ "$VERBOSE" = true ]; then
    verbose_option="-verbose"
else
    verbose_option=""
fi

# Transfering and running configure-host.sh on server1-mgmt
echo "Transferring configure-host.sh to server1-mgmt"
scp configure-host.sh remoteadmin@server1-mgmt:/root || { echo "Failed to transfer configure-host.sh to server1-mgmt" 1>&2; exit 1; }

echo "Running configure-host.sh on server1-mgmt"
ssh remoteadmin@server1-mgmt -- /root/configure-host.sh $verbose_option -name loghost -ip 192.168.16.3 -hostentry webhost 192.168.16.4 || { echo "Failed to run configure-host.sh on server1-mgmt" 1>&2; exit 1; }

# Transfering and running configure-host.sh on server2-mgmt
echo "Transferring configure-host.sh to server2-mgmt"
scp configure-host.sh remoteadmin@server2-mgmt:/root || { echo "Failed to transfer configure-host.sh to server2-mgmt" 1>&2; exit 1; }

echo "Running configure-host.sh on server2-mgmt"
ssh remoteadmin@server2-mgmt -- /root/configure-host.sh $verbose_option -name webhost -ip 192.168.16.4 -hostentry loghost 192.168.16.3 || { echo "Failed to run configure-host.sh on server2-mgmt" 1>&2; exit 1; }

# Updating local /etc/hosts
echo "Running configure-host.sh on local machine"
./configure-host.sh $verbose_option -hostentry loghost 192.168.16.3 || { echo "Failed to update local /etc/hosts with loghost 192.168.16.3" 1>&2; exit 1; }

./configure-host.sh $verbose_option -hostentry webhost 192.168.16.4 || { echo "Failed to update local /etc/hosts with webhost 192.168.16.4" 1>&2; exit 1; }

echo "Configuration updates completed successfully"
