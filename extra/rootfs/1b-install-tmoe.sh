apt update
apt install -y expect
/usr/bin/expect << EOF
set timeout 65535
spawn apt upgrade -y

Do not replace bash.bashrc

expect "What would you like to do about it"
send "\r"
expect eof
EOF
curl -LO https://l.tmoe.me/2.awk
/usr/bin/expect << EOF
set timeout 65535
spawn awk -f 2.awk

Agree to the usage agreement

The full matching sentence is not written because the word colors differ and the sentence is split by color characters, making it cumbersome to write

expect "Continue?"
send "Y\r"
expect "Continue?"
send "Y\r"

Switch to GitHub/Gitee

expect "Do you want to"
send "Y\r"

Install whiptail

expect "Do you want to install"
send "Y\r"

Language selection dialog: Press down arrow twice to select language and confirm

expect "language_region"
sleep 1
send "\x0e\x0e\r"

Tmoe dialog: Confirm directly (select proot container) and proceed to initialization

expect "Please use the arrow keys"
sleep 1
send "\r"

Install dependencies

expect "Do you want to"
send "Y\r"

After installation, return to the Tmoe dialog: Confirm directly (select proot container) and continue initialization

expect "Please use the arrow keys"
sleep 1
send "\r"

Color selection dialog: No preference, confirm directly (neon)

expect "Please select the terminal color"
sleep 1
send "\r"

Font selection dialog: No preference, confirm directly (Inconsolata-go)

expect "Please select a terminal font"
sleep 1
send "\r"

Modify numpad dialog: No preference, but I don't want to modify. Press right arrow once to select "no" and press Enter

expect "Do you need to create"
sleep 1
send "\x06\r"

DNS selection dialog: Keep default and press Enter directly

expect "Mainly used for domain name resolution"
sleep 1
send "\r"

"Press Enter to return"

expect "Enter key"
send "\r"

Enable hitokoto (one-word quotes)? No preference, but I don't want to install. Press right arrow once to select "no" and press Enter

expect "Do you need to enable Yiyan"
sleep 1
send "\x06\r"

Confirm timezone Asia/Shanghai: Press Enter directly

expect "Is your timezone Asia"
sleep 1
send "\r"

Share SD card: I choose to share the entire SD directory (3). Press down arrow twice and press Enter

expect "Otherwise it is not recommended that you mount the entire built-in"
sleep 1
send "\x0e\x0e\r"

Share /storage? I choose yes. Press Enter directly

expect "Do you want to share"
sleep 1
send "\r"

"Press Enter to return"

expect "Enter key"
send "\r"

Share HOME: I choose to share the entire directory (3). Press down arrow twice and press Enter

expect "Mount the host's home directory into the container"
sleep 1
send "\x0e\x0e\r"

"Press Enter to return"

expect "Enter key"
send "\r"

"Agree to the license agreement"

expect "Enter key"
send "\r"

Initial configuration completed. For now, do not install a container. Exit to complete Tmoe installation

Container selection interface: Press right arrow twice to select "cancel" and press Enter to exit

expect "Do you want to run"
sleep 1
send "\x06\x06\r"

Tmoe interface: Press right arrow twice to select "cancel" and press Enter to exit

expect "Please use the arrow keys"
sleep 1
send "\x06\x06\r"
expect eof
EOF

echo "Installation completed.run using awk -f 2.awk The startup script is located at ./.local/share/tmoe-linux/git/debian.sh"