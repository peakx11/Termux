#!/data/data/com.termux/files/usr/bin/bash set -euo pipefail IFS=$'\n\t'

Safe + lightweight Termux:X11 desktop installer

- No offensive tools

- No Wine

- No global shell overrides

- Keeps the install focused on a fast desktop stack

ENABLE_AUDIO=0 INSTALL_EDITOR=1 INSTALL_BROWSER=0 DESKTOP_SESSION="xfce4-session" DISPLAY_NUM=":0"

RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m' CYAN='\033[0;36m' WHITE='\033[1;37m' NC='\033[0m'

msg() { printf '%b\n' "${CYAN}[]${NC} $"; } ok()  { printf '%b\n' "${GREEN}[+]${NC} $"; } warn(){ printf '%b\n' "${YELLOW}[!]${NC} $"; } err() { printf '%b\n' "${RED}[x]${NC} $*" >&2; }

need_cmd() { command -v "$1" >/dev/null 2>&1 || { err "Missing required command: $1"; exit 1; } }

pkg_install() { msg "Installing: $*" pkg install -y "$@" }

main() { clear || true cat <<'BANNER'

Termux Safe Desktop Installer Termux:X11 + XFCE4

BANNER

need_cmd pkg

msg "Updating base packages" pkg update -y pkg upgrade -y

msg "Enabling X11 repository" pkg_install x11-repo

msg "Installing desktop essentials" pkg_install termux-x11-nightly dbus xfce4 xfce4-terminal thunar mousepad

if [ "$INSTALL_BROWSER" -eq 1 ]; then pkg_install firefox fi

if [ "$INSTALL_EDITOR" -eq 1 ]; then pkg_install git curl wget fi

if [ "$ENABLE_AUDIO" -eq 1 ]; then pkg_install pulseaudio fi

mkdir -p "$HOME/.config/termux-desktop" "$HOME/bin"

cat > "$HOME/.config/termux-desktop/start-desktop.sh" <<EOF #!/data/data/com.termux/files/usr/bin/bash set -e export DISPLAY=${DISPLAY_NUM} export XDG_RUNTIME_DIR="${TMPDIR:-/data/data/com.termux/files/usr/tmp}" export PULSE_SERVER=127.0.0.1

Start the X server first.

termux-x11 ${DISPLAY_NUM} -ac & sleep 2

Start dbus if available; XFCE works best with a session bus.

if command -v dbus-launch >/dev/null 2>&1; then exec dbus-launch --exit-with-session ${DESKTOP_SESSION} else exec ${DESKTOP_SESSION} fi EOF chmod +x "$HOME/.config/termux-desktop/start-desktop.sh"

cat > "$HOME/.config/termux-desktop/stop-desktop.sh" <<'EOF' #!/data/data/com.termux/files/usr/bin/bash pkill -f 'termux-x11' 2>/dev/null || true pkill -f 'xfce4-session' 2>/dev/null || true pkill -f 'xfce4-terminal' 2>/dev/null || true pkill -f 'dbus-daemon' 2>/dev/null || true pkill -f 'pulseaudio' 2>/dev/null || true EOF chmod +x "$HOME/.config/termux-desktop/stop-desktop.sh"

cat > "$HOME/bin/start-desktop" <<'EOF' #!/data/data/com.termux/files/usr/bin/bash exec "$HOME/.config/termux-desktop/start-desktop.sh" EOF chmod +x "$HOME/bin/start-desktop"

cat > "$HOME/bin/stop-desktop" <<'EOF' #!/data/data/com.termux/files/usr/bin/bash exec "$HOME/.config/termux-desktop/stop-desktop.sh" EOF chmod +x "$HOME/bin/stop-desktop"

if ! grep -q 'HOME/bin' "$HOME/.bashrc" 2>/dev/null; then printf '\nexport PATH="$HOME/bin:$PATH"\n' >> "$HOME/.bashrc" fi

ok "Installed safely and kept minimal." echo echo "Start the desktop with: start-desktop" echo "Stop it with: stop-desktop" echo warn "For best performance, keep the desktop minimal and avoid installing extra apps you do not need." }

main "$@"
