#!/bin/bash

# Netplan Configuration
echo "Configuring netplan..."
cat <<EOF | sudo tee /etc/netplan/01-netcfg.yaml >/dev/null
network:
  version: 2
  ethernets:
    ens3:
      addresses:
        - 192.168.16.21/24
EOF

sudo chmod 0644 /etc/netplan/01-netcfg.yaml
sudo chown root:root /etc/netplan/01-netcfg.yaml

sudo netplan apply
echo "Netplan configuration applied."

# Updating /etc/hosts
echo "Updating /etc/hosts..."
sudo sed -i '/192.168.16.21/s/^#//g' /etc/hosts
sudo sed -i '/old-address/d' /etc/hosts
echo "/etc/hosts updated."

# Installing Software
echo "Installing Apache2 and Squid..."
sudo apt-get update
sudo apt-get install -y apache2 squid
echo "Software installation complete."

# Configuring Firewall with ufw
echo "Configuring ufw firewall..."
# Ensure ufw is installed and available
if ! command -v ufw &> /dev/null
then
    echo "ufw command not found. Installing ufw..."
    sudo apt-get install -y ufw
fi

sudo ufw allow ssh
sudo ufw allow from 192.168.16.0/24 to any port 80
sudo ufw allow from 192.168.16.0/24 to any port 3128
sudo ufw --force enable  # Enable firewall forcefully
echo "Firewall configured with ufw."

# Creating User Accounts and SSH Keys
echo "Creating user accounts and configuring SSH keys..."

# List of users and their SSH keys
declare -A users=(
    ["dennis"]="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI alsha@generic-vm"
    ["aubrey"]=""
    ["captain"]=""
    ["snibbles"]=""
    ["brownie"]=""
    ["scooter"]=""
    ["sandy"]=""
    ["perrier"]=""
    ["cindy"]=""
    ["tiger"]=""
    ["yoda"]=""
)

# Loop through each user and configure
for user in "${!users[@]}"
do
    echo "Configuring user: $user"
    sudo useradd -m -s /bin/bash "$user"
    sudo mkdir -p /home/$user/.ssh
    sudo chmod 700 /home/$user/.ssh
    if [[ -n "${users[$user]}" ]]; then
        sudo bash -c "echo '${users[$user]}' >> /home/$user/.ssh/authorized_keys"
        sudo chmod 600 /home/$user/.ssh/authorized_keys
        sudo chown -R $user:$user /home/$user/.ssh
    fi
done

echo "User accounts and SSH keys configured."

# Granting sudo access to dennis
echo "Granting sudo access to dennis..."
sudo usermod -aG sudo dennis
echo "Sudo access granted to dennis."

# Output summary
echo "Configuration completed successfully."

