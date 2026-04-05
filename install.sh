#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "[*] Updating packages..."
pkg update -y && pkg upgrade -y

echo "[*] Installing X11 repo..."
pkg install -y x11-repo

echo "[*] Installing desktop..."
pkg install -y termux-x11-nightly dbus xfce4 xfce4-terminal thunar mousepad git curl wget

echo "[*] Creating launch scripts..."

mkdir -p ~/.config/termux-desktop
mkdir -p ~/bin

cat > ~/.config/termux-desktop/start-desktop.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
export DISPLAY=:0

termux-x11 :0 -ac &
sleep 2

if command -v dbus-launch >/dev/null 2>&1; then
    exec dbus-launch --exit-with-session xfce4-session
else
    exec xfce4-session
fi
EOF

chmod +x ~/.config/termux-desktop/start-desktop.sh

cat > ~/.config/termux-desktop/stop-desktop.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
pkill -f termux-x11 2>/dev/null
pkill -f xfce4-session 2>/dev/null
pkill -f dbus-daemon 2>/dev/null
EOF

chmod +x ~/.config/termux-desktop/stop-desktop.sh

cat > ~/bin/start-desktop << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
bash ~/.config/termux-desktop/start-desktop.sh
EOF

chmod +x ~/bin/start-desktop

cat > ~/bin/stop-desktop << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
bash ~/.config/termux-desktop/stop-desktop.sh
EOF

chmod +x ~/bin/stop-desktop

echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc

echo ""
echo "[+] DONE!"
echo "Run: start-desktop"
