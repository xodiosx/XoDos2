#!/bin/bash

# Container names should not contain underscores, otherwise they cannot be deleted

if [ -z "$1" ]; then
    echo "Usage: $0 <name_of_container>"
    exit 1
fi

/usr/bin/expect <<EOF
set timeout 65535
spawn bash $HOME/.local/share/tmoe-linux/git/debian.sh
# Tmoe interface
expect "Please use the arrow keys"
sleep 1
send "\r"
# Architecture selection page
expect "Do you want to run"
sleep 1
send "\r"
# System selection page: choose the first one (Debian), press Enter directly
expect "Which container do you want to install"
sleep 1
send "\r"
# Version selection page: choose the second one (Debian 12), press down arrow then Enter
expect "Please select what you need to install"
sleep 1
send "\x0e\r"
# Container settings page: choose the ninth option (New container) to rename the new container for differentiation. Press down arrow 8 times then Enter
expect "container path"
sleep 1
send "\x0e\x0e\x0e\x0e\x0e\x0e\x0e\x0e\r"
# Enter container name for future access
expect "Please"
sleep 1
send "$1\r"
# Confirm installation
expect "Will be installed for you soon"
send "\r"

# Whether to create a new sudo user: confirm
expect "Do you want to create a new one?"
sleep 1
send "\r"
# Create user named "xodos"
expect "Please enter username"
sleep 1
send "xodos\r"
# Set password also as "xodos"
expect "password"
sleep 1
send "xodos\r"
# Set xodos as default user: choose yes (press right arrow then Enter)
expect "Do you want to "
sleep 1
send "\x06\r"
# Whether to configure zsh: choose no (press right arrow then Enter)
expect "Does it need to be"
sleep 1
send "\x06\r"
# Whether to delete zsh configuration script: choose yes (press Enter directly)
expect "delete"
sleep 1
send "\r"
# Whether to enable tmoe: choose yes (press Enter directly)
expect "Does it need to be started?"
sleep 1
send "\r"
# Configure fontconfig-config: keep all defaults, press Enter 4 times
expect "Configuring fontconfig-config"
sleep 1
send "\r"
expect "Configuring fontconfig-config"
sleep 1
send "\r"
expect "Configuring fontconfig-config"
sleep 1
send "\r"
expect "Configuring fontconfig-config"
sleep 1
send "\r"
# Post-installation fontconfig-config configuration: press Enter directly
expect "Configuring fontconfig-config"
sleep 1
send "\r"
# Arrive at Tmoe tools interface: exit first (press right arrow twice then Enter)
expect "graphical interface"
sleep 1
send "\x06\x06\r"
# Exit to complete installation
expect "root@localhost"
send "exit\r"
# Continue exiting to complete installation
expect "root@localhost"
send "exit\r"
# Continue exiting to complete installation
expect "xodos@localhost"
send "exit\r"
# "Press Enter to return"
expect "Enter key"
send "\r"
# Exit container settings page: press right arrow twice then Enter
expect "Container path"
sleep 1
send "\x06\x06\r"
# Exit container installation page: press right arrow twice then Enter
expect "which container do you want to install"
sleep 1
send "\x06\x06\r"
# Exit architecture selection page: press right arrow twice then Enter
expect "Do you want to run"
sleep 1
send "\x06\x06\r"
# Exit Tmoe interface: press right arrow twice then Enter
expect "Please use the arrow keys"
sleep 1
send "\x06\x06\r"
expect eof
EOF
echo "Installation complete! You can now enter the container using 'tmoe p debian-$1'."