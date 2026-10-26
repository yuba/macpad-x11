#!/bin/sh
# Shown after installing the .deb or .rpm package.
cat <<'MSG'
==> macpad-x11 starts automatically at your next X11 login.
==> To start it now:   systemctl --user start macpad-x11.service
==> Your user must be in the 'input' group:  sudo gpasswd -a "$USER" input
==> Config example:    /usr/share/doc/macpad-x11/config.example.ini
==>   copy it to ~/.config/macpad-x11/config.ini to customize.
MSG
