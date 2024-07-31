#!/bin/bash

# Ignoring signals
trap '' TERM HUP INT

# Initializing variables
VERBOSE=false
DESIRED_NAME=""
DESIRED_IP=""
HOST_ENTRY_NAME=""
HOST_ENTRY_IP=""

# Checking for verbose mode
for arg in "$@"; do
    if [ "$arg" == "-verbose" ]; then
        VERBOSE=true
    fi
done

# Parsing command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -name)
            shift
            DESIRED_NAME="$1"
            ;;
        -ip)
            shift
            DESIRED_IP="$1"
            ;;
        -hostentry)
            shift
            HOST_ENTRY_NAME="$1"
            shift
            HOST_ENTRY_IP="$1"
            ;;
        *)
            ;;
    esac
    shift
done

# Function to print messages in verbose mode
log() {
    if [ "$VERBOSE" = true ]; then
        echo "$1"
    fi
}

# Updating hostname if required
if [ -n "$DESIRED_NAME" ]; then
    CURRENT_NAME=$(hostname)
    if [ "$CURRENT_NAME" != "$DESIRED_NAME" ]; then
        log "Changing hostname from $CURRENT_NAME to $DESIRED_NAME"
        echo "$DESIRED_NAME" | sudo tee /etc/hostname
        sudo sed -i "s/127.0.1.1\s*$CURRENT_NAME/127.0.1.1 $DESIRED_NAME/" /etc/hosts
        sudo hostnamectl set-hostname "$DESIRED_NAME"
        logger "Hostname changed from $CURRENT_NAME to $DESIRED_NAME"
    else
        log "Hostname already set to $DESIRED_NAME"
    fi
fi

# Updating IP address if required
if [ -n "$DESIRED_IP" ]; then
    # Check for current IP address
    CURRENT_IP=$(hostname -I | awk '{print $1}')
    
    # Updating /etc/hosts with the new IP address
    if [ "$CURRENT_IP" != "$DESIRED_IP" ]; then
        log "Changing IP address from $CURRENT_IP to $DESIRED_IP"
        sudo sed -i "s/${CURRENT_IP}/${DESIRED_IP}/g" /etc/hosts

        # Netplan configuration file path
        NETPLAN_FILE="/etc/netplan/01-network-manager-all.yaml"

        if [ -e "$NETPLAN_FILE" ]; then
            # Update IP address in the Netplan configuration file
            sudo sed -i "s/addresses: \[.*\]/addresses: [${DESIRED_IP}\/24]/" "$NETPLAN_FILE"
            # Apply Netplan configuration
            sudo netplan apply
            logger "IP address changed from $CURRENT_IP to $DESIRED_IP"
        else
            log "Netplan file $NETPLAN_FILE not found"
        fi
    else
        log "IP address already set to $DESIRED_IP"
    fi
fi

# Updating /etc/hosts with host entry if required
if [ -n "$HOST_ENTRY_NAME" ] && [ -n "$HOST_ENTRY_IP" ]; then
    ENTRY="${HOST_ENTRY_IP} ${HOST_ENTRY_NAME}"
    if ! grep -q "$ENTRY" /etc/hosts; then
        log "Adding host entry: $ENTRY"
        echo "$ENTRY" | sudo tee -a /etc/hosts
        logger "Added host entry: $ENTRY"
    else
        log "Host entry $ENTRY already exists"
    fi
fi

