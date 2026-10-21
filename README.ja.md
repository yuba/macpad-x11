# three-finger-drag

X11 上の Linux タッチパッドで、macOS のような三本指ドラッグを実現します。

[English](README.md)

- 三本指スワイプでドラッグ（ウィンドウ、ファイル、テキスト選択など）
- 指を一瞬離してもう一度置けば、**同じドラッグを続けられます**（Mac と同じ）
- 本当に終わらせたいときは、一本指でポインターを動かす・クリック・スクロールすれば、
  対象を引きずることなく**即座に**ドラッグが終わります
- Python スクリプト 1 本。コンパイル不要、root デーモン不要、fusuma や touchegg も不要

## 動作要件

- **X11** セッション（Wayland 非対応。Wayland では compositor によって libinput 標準の三本指ドラッグが使える場合があります）
- Python 3.11 以降
- `libinput`（`libinput debug-events` コマンド。Debian/Ubuntu では `libinput-tools` パッケージ）
- `libXtst`（Arch: `libxtst` / Debian・Ubuntu: `libxtst6` / Fedora: `libXtst`）
- ユーザーが `input` グループに所属していること

  ```sh
  sudo gpasswd -a "$USER" input   # その後ログインし直す
  ```

## インストール

### Arch Linux / Manjaro（AUR）

```sh
yay -S three-finger-drag
systemctl --user start three-finger-drag.service   # またはログインし直す
```

### その他のディストリビューション

```sh
git clone https://github.com/yuba/three-finger-drag.git
cd three-finger-drag
./install.sh
```

`~/.local/bin` へのインストール、systemd ユーザーサービスと XDG autostart の登録、
デーモンの起動までを行います。アンインストールは:

```sh
./install.sh --uninstall
```

## 設定

`~/.config/three-finger-drag/config.toml`（[config.example.toml](config.example.toml) 参照）

| キー         | 既定値 | 意味                                                   |
|--------------|--------|--------------------------------------------------------|
| `timeout`    | `0.5`  | 指を離した後の猶予時間（秒）                           |
| `lift_guard` | `0.0`  | スワイプ終了直後にポインターイベントを無視する時間（秒） |
| `speed`      | `3.0`  | スワイプ量に対するポインター移動量の倍率               |
| `fingers`    | `3`    | ドラッグを開始する指の本数                             |

変更の反映:

```sh
systemctl --user reload three-finger-drag.service
```

## 競合

fusuma、touchegg、libinput-gestures、デスクトップ環境自身のジェスチャーなどで
三本指スワイプに割り当てがあれば無効にしてください。同じスワイプに両方が反応します。

## 仕組み

デーモンは `libinput debug-events` を読み、小さな状態機械で動きます。

1. `GESTURE_SWIPE_BEGIN`（3 本指）→ XTest で左ボタンを押す
2. `GESTURE_SWIPE_UPDATE` → スワイプ量だけポインターを動かす
3. `GESTURE_SWIPE_END` → ボタンを押したまま猶予期間に入る
4. 猶予期間中:
   - 再び三本指スワイプ → ドラッグ継続
   - `POINTER_MOTION`・`POINTER_BUTTON`・スクロール・ピンチ → 即座に解除
   - タイムアウト → 解除

要点は 2 つです。

- **常駐が必須。** libinput は起動時点で既に触れている指を追跡しないため、
  ドラッグのたびに監視プロセスを起動すると、そのドラッグの指を見られません。
- **カーソル座標のポーリングではなく libinput のイベントに反応する。**
  三本のうち二本を離すと、libinput はスワイプを終了し、約 4ms 後に残った指の
  `POINTER_MOTION` を出します。その時点でボタンを離すので、対象を引きずりません。

## トラブルシューティング

```sh
systemctl --user status three-finger-drag.service
journalctl --user -u three-finger-drag.service
```

ボタンが押されたままになったように見えたら、
`systemctl --user restart three-finger-drag.service` で解放されます。

## ライセンス

MIT
