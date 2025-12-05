#!/bin/bash
if [ -z "$1" ]; then
    echo "Usage: $0 <name_of_container>"
    exit 1
fi
/usr/bin/expect <<EOF
set timeout 65535
spawn tmoe p "debian-$1"
expect "xodos@localhost"
# Impersonate root user (mainly to avoid colors in xodos@localhost)
send "sudo su\n"
# Install GXDE source
expect "root@localhost"
send {wget https://mirrors.sdu.edu.cn/spark-store/GXDE-OS/gxde-os/bixie/g/gxde-source/gxde-source_1.1.6_all.deb}
send "\r"
expect "root@localhost"
send {apt install ./gxde-source_1.1.6_all.deb -y}
send "\r"
expect "root@localhost"
send {rm gxde-source_1.1.6_all.deb}
send "\r"
expect "root@localhost"
send "apt update\r"
expect "root@localhost"
send "apt upgrade -y\r"
# Update twice to ensure all source updates are applied
expect "root@localhost"
send "apt update\r"
expect "root@localhost"
send "apt upgrade -y\r"
# Install xdg-utils (required by Spark Store)
expect "root@localhost"
send "apt install xdg-utils -y\r"
# Official installation
expect "root@localhost"
send "apt install gxde-desktop-android --no-install-recommends -y\r"
# PAM configuration
expect "PAM Configuration"
sleep 1
send "\r"

# Modify VNC installation script
expect "root@localhost"
send {sed -i 's/gui_main "\$@"/configure_vnc_xstartup/' /usr/local/etc/tmoe-linux/git/share/old-version/tools/gui/gui}
send "\r"
# Enter tmoe tools
expect "root@localhost"
send "tmoe t\r"
# Press down arrow 4 times and Enter to enter VNC installation
expect "Welcome to tmoe linux tools"
sleep 1
send "\x0e\x0e\x0e\x0e\r"
# Select VNC client: TigerVNC
expect "Although tight may be smoother"
sleep 1
send "\r"
# Password: 12345678
expect "Please type the password"
sleep 1
send "12345678\r"
# Port selection (choose default)
expect "Please choose a vnc port"
sleep 1
send "\r"
# Confirm installation
expect "then you only need to remember 4 commands"
sleep 1
send "\r"
# Install x11vnc
expect "Do you want to configure x11vnc"
sleep 1
send "\r"
# Install novnc
expect "Do you want to configure novnc"
sleep 1
send "\r"
# Paper size selection
expect "Please select the default paper"
sleep 1
send "\r"
# Close prompts
expect "You can type startvnc"
sleep 1
send "\r"
expect "Press Enter"
sleep 1
send "\r"
# Press down arrow 4 times and Enter to enter VNC settings
expect "Welcome to tmoe linux tools"
sleep 1
send "\x0e\x0e\x0e\x0e\r"
# Modify TigerVNC configuration
expect "Which remote desktop config"
sleep 1
send "\r"
# Modify other configuration: press right arrow and Enter
expect "Which configuration do you want to modify"
sleep 1
send "\x06\r"
# Press down arrow 9 times and Enter to enter display port setting
expect "Type startvnc to start"
sleep 1
send "\x0e\x0e\x0e\x0e\x0e\x0e\x0e\x0e\x0e\r"
# Enter number 4 (port 5904) and confirm
expect "Please type the display"
sleep 1
send "4\r"
expect "Press Enter"
sleep 1
send "\r"
# Press right arrow twice and Enter to return
expect "Type startvnc to start"
sleep 1
send "\x06\x06\r"
# Modify novnc configuration: press down arrow 3 times and Enter
expect "Which remote desktop config"
sleep 1
send "\x0e\x0e\x0e\r"
# Modify port
expect "Type novnc to start novnc"
sleep 1
send "\r"
# Enter port: 36082
expect "Please type the novnc port"
sleep 1
send "36082\r"
expect "Press Enter"
sleep 1
send "\r"
# Press right arrow twice and Enter to return
expect "Type novnc to start novnc"
sleep 1
send "\x06\x06\r"
expect "Which remote desktop config"
sleep 1
send "\x06\x06\r"
expect "Welcome to tmoe linux tools"
sleep 1
send "\x06\x06\r"
# Revert script modifications
expect "root@localhost"
send {sed -i '/^[[:space:]]*configure_vnc_xstartup[[:space:]]*$/s/configure_vnc_xstartup/gui_main "\$@"/' /usr/local/etc/tmoe-linux/git/share/old-version/tools/gui/gui}
send "\r"
# Set GXDE startup script
expect "root@localhost"
send "cat <<EOF > /etc/X11/xinit/Xsession
rm -rf /run/dbus/pid
sudo dbus-daemon --system
export \$(dbus-launch)
startgxde_android
EOF\r"
expect "root@localhost"
send "exit\r"
expect "xodos@localhost"
send "exit\r"
expect eof
EOF

# TODO: Fix startnovnc, Xsession failure, Pinyin input method, Firefox, VSCode