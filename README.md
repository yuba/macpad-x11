# three-finger-drag

macOS-style three-finger drag for Linux touchpads on X11.

[日本語](README.ja.md)

- Swipe with three fingers to drag (windows, files, text selections, …).
- Lift your fingers briefly and put them back to **continue the same drag**,
  just like on a Mac.
- When you really want to stop, just move the pointer with one finger, click
  or scroll: the drag ends **immediately**, without dragging the object along.
- One small Python script. No compilation, no root daemon, no fusuma or
  touchegg needed.

## Requirements

- An **X11** session (Wayland is not supported; some Wayland compositors offer
  libinput's built-in three-finger drag instead)
- Python 3.11 or later
- `libinput` (the `libinput debug-events` command — on Debian/Ubuntu it is in
  the `libinput-tools` package)
- `libXtst` (`libxtst` on Arch, `libxtst6` on Debian/Ubuntu, `libXtst` on Fedora)
- Your user in the `input` group:

  ```sh
  sudo gpasswd -a "$USER" input   # then log out and back in
  ```

## Install

### Arch Linux / Manjaro

Build and install a pacman package with the bundled `PKGBUILD`:

```sh
git clone https://github.com/yuba/three-finger-drag.git
cd three-finger-drag
makepkg -si
systemctl --user start three-finger-drag.service   # or just log in again
```

`makepkg` downloads the tagged release and installs the dependencies.
Uninstall with `sudo pacman -R three-finger-drag`.

### Any distribution

```sh
git clone https://github.com/yuba/three-finger-drag.git
cd three-finger-drag
./install.sh
```

This installs into `~/.local/bin`, registers a systemd user service and an
XDG autostart entry, and starts the daemon. To remove it:

```sh
./install.sh --uninstall
```

## Configuration

`~/.config/three-finger-drag/config.toml` (see
[config.example.toml](config.example.toml)):

| key          | default | meaning                                                         |
|--------------|---------|-----------------------------------------------------------------|
| `timeout`    | `0.5`   | Grace period (s) after lifting the fingers                      |
| `lift_guard` | `0.0`   | Ignore pointer events this long (s) right after the swipe ends  |
| `speed`      | `3.0`   | Pointer movement per unit of swipe movement                     |
| `fingers`    | `3`     | Number of fingers that start a drag                             |

Apply changes with:

```sh
systemctl --user reload three-finger-drag.service
```

## Conflicts

Disable any other three-finger swipe bindings (fusuma, touchegg, libinput-gestures,
your desktop's own gestures); otherwise both will act on the same swipe.

## How it works

The daemon reads `libinput debug-events` and keeps a tiny state machine:

1. `GESTURE_SWIPE_BEGIN` (3 fingers) → press the left button via XTest
2. `GESTURE_SWIPE_UPDATE` → move the pointer by the swipe delta
3. `GESTURE_SWIPE_END` → start the grace period, button still held
4. During the grace period:
   - another three-finger swipe → continue the drag
   - `POINTER_MOTION`, `POINTER_BUTTON`, scroll or pinch → release now
   - timeout → release

Two details matter:

- **It must stay resident.** libinput ignores touches that were already on the
  touchpad when it started, so a watcher spawned at the beginning of each drag
  would never see the fingers that started it.
- **Reacting to libinput events, not polling the cursor.** When you lift two
  of three fingers, libinput ends the swipe and emits the remaining finger's
  `POINTER_MOTION` about 4 ms later; the daemon releases the button right
  there, so the object is not dragged along.

## Troubleshooting

```sh
systemctl --user status three-finger-drag.service
journalctl --user -u three-finger-drag.service
```

If the button ever seems stuck, `systemctl --user restart three-finger-drag.service`
releases it.

## License

MIT
