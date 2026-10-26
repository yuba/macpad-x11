#!/bin/sh
# Per-user installer for macpad-x11.
#   ./install.sh              install into ~/.local and start the daemon
#   ./install.sh --uninstall  stop the daemon and remove the installed files
set -eu

NAME=macpad-x11
SRC=$(cd "$(dirname "$0")" && pwd)
BIN_DIR=${PREFIX:-$HOME/.local}/bin
DATA_DIR=${XDG_DATA_HOME:-$HOME/.local/share}/$NAME
CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
UNIT_DIR=$CONFIG_HOME/systemd/user
AUTOSTART_DIR=$CONFIG_HOME/autostart
CONF_DIR=$CONFIG_HOME/$NAME

info() { printf '==> %s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

uninstall() {
  systemctl --user disable --now "$NAME.service" 2>/dev/null || true
  rm -f "$BIN_DIR/$NAME" "$UNIT_DIR/$NAME.service" "$AUTOSTART_DIR/$NAME.desktop" "$DATA_DIR/apps.ini"
  rmdir "$DATA_DIR" 2>/dev/null || true
  systemctl --user daemon-reload
  info "removed. Your config is kept in $CONF_DIR"
}

check_deps() {
  python3 -c 'import sys; sys.exit(sys.version_info < (3, 8))' 2>/dev/null \
    || die "python3 >= 3.8 is required"
  command -v libinput >/dev/null || die "libinput (with debug-events) is required"
  command -v stdbuf >/dev/null || die "stdbuf (coreutils) is required"
  python3 -c 'import ctypes; ctypes.cdll.LoadLibrary("libXtst.so.6")' 2>/dev/null \
    || die "libXtst is required (e.g. libxtst / libxtst6 / libXtst)"
  if ! id -nG | tr ' ' '\n' | grep -qx input; then
    warn "you are not in the 'input' group; libinput cannot read the touchpad"
    warn "and the virtual touchscreen for pinch zoom cannot be created."
    warn "run: sudo gpasswd -a $(id -un) input   (then log out and back in)"
  fi
  if [ "${XDG_SESSION_TYPE:-}" = wayland ]; then
    warn "Wayland session detected; $NAME works on X11 only."
  fi
}

install_files() {
  install -Dm755 "$SRC/$NAME" "$BIN_DIR/$NAME"
  install -Dm644 "$SRC/apps.ini" "$DATA_DIR/apps.ini"
  mkdir -p "$UNIT_DIR"
  sed "s|^ExecStart=.*|ExecStart=$BIN_DIR/$NAME|" "$SRC/$NAME.service" > "$UNIT_DIR/$NAME.service"
  install -Dm644 "$SRC/$NAME.desktop" "$AUTOSTART_DIR/$NAME.desktop"
  if [ ! -e "$CONF_DIR/config.ini" ]; then
    install -Dm644 "$SRC/config.example.ini" "$CONF_DIR/config.ini"
  fi
  systemctl --user daemon-reload
}

case "${1:-}" in
  --uninstall) uninstall; exit 0 ;;
  "") ;;
  *) die "usage: $0 [--uninstall]" ;;
esac

check_deps
install_files
info "installed $BIN_DIR/$NAME"
info "config: $CONF_DIR/config.ini"
if [ -n "${DISPLAY:-}" ]; then
  systemctl --user import-environment DISPLAY XAUTHORITY 2>/dev/null || true
  systemctl --user restart "$NAME.service"
  info "started. It will start automatically at login."
else
  info "it will start at your next graphical login."
fi
