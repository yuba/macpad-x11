# macpad-x11

X11 上の Linux タッチパッドで、macOS のようなジェスチャーを実現します。

[English](README.md)

- **三本指ドラッグ。** 三本指スワイプでウィンドウ・ファイル・テキスト選択をドラッグ。
  指を一瞬離してもう一度置けば**同じドラッグを続けられます**（Mac と同じ）。
  一本指でポインターを動かす・クリック・スクロールすれば即座に終わります。
- **ポインターを中心にしたピンチズーム。** ズーム中もポインターの下の場所が動かず、
  ピンチしながら指を動かせばパンもできます。Chrome などの Chromium / Electron アプリでは、
  X11 版 Chrome がタッチパッドのピンチを無視するにもかかわらず、ネイティブの滑らかなズームになります。
  その他のアプリはホイールやキーで操作します。どれを使うかは [apps.toml](apps.toml) に書かれていて、
  コードに触れずに自分でアプリを追加できます。
- Python スクリプト 1 本。コンパイル不要、root デーモン不要、fusuma や touchegg も不要

macpad-x11 は、ピンチを覚える前は three-finger-drag という名前でした。

## 動作要件

- **X11** セッション（Wayland 非対応）
- Python 3.11 以降
- `libinput`（`libinput debug-events` コマンド。Debian/Ubuntu では `libinput-tools` パッケージ）
- `libX11` と `libXtst`（Arch: `libx11 libxtst` / Debian・Ubuntu: `libx11-6 libxtst6` / Fedora: `libX11 libXtst`）
- ユーザーが `input` グループに所属していること（タッチパッドの読み取りと、
  ピンチズーム用の仮想タッチスクリーンの作成に必要）

  ```sh
  sudo gpasswd -a "$USER" input   # その後ログインし直す
  ```

## インストール

### Arch Linux / Manjaro

同梱の `PKGBUILD` で pacman パッケージをビルドしてインストールします。

```sh
git clone https://github.com/yuba/macpad-x11.git
cd macpad-x11
makepkg -si
systemctl --user start macpad-x11.service   # またはログインし直す
```

`makepkg` がタグ付きリリースのダウンロードと依存パッケージのインストールを行います。
このパッケージは three-finger-drag を置き換えます。アンインストールは `sudo pacman -R macpad-x11` です。

### その他のディストリビューション

```sh
git clone https://github.com/yuba/macpad-x11.git
cd macpad-x11
./install.sh
```

`~/.local` へのインストール、systemd ユーザーサービスと XDG autostart の登録、
デーモンの起動までを行います。ユーザー単位でインストールされた three-finger-drag は
削除され、その設定は引き継がれます。アンインストールは:

```sh
./install.sh --uninstall
```

## 設定

`~/.config/macpad-x11/config.toml`。すべての項目は省略可能です。全項目は
[config.example.toml](config.example.toml) を参照してください。

```toml
[drag]
timeout = 0.5      # 指を離した後の猶予時間（秒）
speed = 3.0        # スワイプ量に対するポインター移動量の倍率

[pinch]
enabled = true

[apps."Some-app"]  # WM_CLASS のクラス名。apps.toml より優先
zoom = "wheel"
modifier = "ctrl"
step = 1.1
pan = "wheel"
```

変更は `systemctl --user reload macpad-x11.service` で反映されます。

## ピンチズームと apps.toml

ポインターを中心にズームさせる方法はアプリごとに違うため、[apps.toml](apps.toml) に
WM_CLASS ごとに、いくつかの汎用的な方式のどれを使うかを書いてあります。

| `zoom`  | macpad-x11 が送るもの                                          | 向いているアプリ                     |
|---------|----------------------------------------------------------------|--------------------------------------|
| `touch` | 仮想タッチスクリーン上の二本指ピンチ（一本はポインター上に固定） | Chromium、Electron、一部の GTK アプリ。滑らかでパンも可 |
| `wheel` | `modifier` を押しながらのポインター位置でのホイール             | （Ctrl+）ホイールでポインター中心にズームするアプリ |
| `keys`  | `zoom_in` / `zoom_out` のキー入力                               | 最後の手段。アプリ自身の中心でズーム |
| `none`  | 何もしない                                                     | 自前でピンチを処理するアプリ         |

`wheel` と `keys` では、`step` はアプリ側の 1 クリック（1 打鍵）あたりの倍率で、
`pan = "wheel"` を指定するとピンチ中の指の移動をホイールでのパンに変換します。
載っていないアプリには `[pinch.default]`（`zoom = "keys"`）が使われます。

項目は WM_CLASS の両方の部分（クラス名とインスタンス名）に、大文字・小文字を区別せずに照合され、
ワイルドカードも使えます。たとえば `"vivaldi*"` はネイティブ版と Flatpak 版の両方に一致します。

### 対応アプリ

`tools/probe` で計測（2026 年 10 月）:

| | ポインター中心のズーム | ピンチ中のパン |
|---|---|---|
| Chrome、Chromium、Brave、Edge | 滑らか（`touch`） | あり |
| Vivaldi | 滑らか（`touch`）、中心が少しずれる | 未確認 |
| Firefox | 滑らか（`touch`）— 下記参照 | 未確認 |
| GIMP、Inkscape、Krita、Eye of GNOME | 滑らか（`touch`） | 未確認 |
| Evince | 段階的（`wheel`） | あり |
| Gwenview | 段階的（`keys`） | あり |
| Papers、Xournal++、Ristretto、Viewnior、gThumb、nomacs、Loupe | 段階的（`wheel`） | なし |
| zathura | ズームはするが表示領域の中心が基準（`wheel`） | なし |

**Firefox** は、環境変数 `MOZ_USE_XINPUT2=1` を付けて起動したときだけタッチスクリーンのピンチを扱います
（たとえば `~/.xprofile` に `export MOZ_USE_XINPUT2=1`）。設定したら config.toml に次を追加してください。

```toml
[apps.firefox]
zoom = "touch"
```

未対応: Okular、LibreOffice、KolourPaint には macpad-x11 から呼び出せるポインター中心のズームがありません。
VS Code などの Electron アプリはピンチズームを無効にしています。Pinta は WM_CLASS（`dotnet`）で見分けられません。
これらには既定の `keys` が使われます。

### アプリを追加する

`tools/probe` が適切な設定を調べてくれます。xdotool、ImageMagick、
numpy と OpenCV の入った Python が必要です。

```sh
python3 -m venv .venv && .venv/bin/pip install numpy opencv-python-headless
tools/make-testdata                 # testdata/ に方眼の文書を生成
# アプリで testdata/grid.{png,pdf,svg,html} を開いてから:
.venv/bin/python tools/probe -o probe.png
# 3 秒以内にアプリのウィンドウにポインターを合わせる
```

合成したピンチで全方式を試し（タッチパッドや動作中のサービスには影響しません）、
内容がどれだけずれたかを測って、設定ファイルや apps.toml に貼れる設定を出力します。
歓迎画面などのダイアログは先に閉じ、比較画像も目で確認してください。模様の少ない文書だと計測を誤ることがあります。
タッチスクリーンのピンチでズームしないアプリには、決して `zoom = "touch"` を設定しないでください。
X が仮想の指をマウスのドラッグとして扱ってしまいます。
アプリを追加するプルリクエストを歓迎します。比較画像 `probe.png` を添付してください。

## 競合

fusuma、touchegg、libinput-gestures、デスクトップ環境自身のジェスチャーなどで
三本指スワイプや二本指ピンチに割り当てがあれば無効にしてください。同じジェスチャーに両方が反応します。

## 仕組み

デーモンは `libinput debug-events` を読みます。

**ドラッグ。** 小さな状態機械です。三本指の `GESTURE_SWIPE_BEGIN` で XTest により左ボタンを押し、
更新でポインターを動かし、`GESTURE_SWIPE_END` でボタンを押したまま猶予期間に入ります。
再びスワイプすれば継続、`POINTER_MOTION`・クリック・スクロール・ピンチで即座に解除、
それ以外は猶予期間の終わりに解除します。libinput は起動時点で既に触れている指を追跡しないため常駐が必須で、
カーソル座標のポーリングではなく libinput のイベントに反応します。三本のうち二本を離すと、
約 4ms 後に残った指の `POINTER_MOTION` が届き、その時点でボタンを離すので対象を引きずりません。

**ピンチ。** `GESTURE_PINCH_BEGIN` でポインターの下のウィンドウの WM_CLASS を調べます。
`touch` では uinput の仮想タッチスクリーンでピンチを再現します。一本目の指はポインター上に固定し、
二本目をピンチの倍率に合わせて動かします。タッチのピンチでは内容が指に追従するので、
一本目の指（＝ポインター）の下の場所が動かず、X はカーソルを一本目のタッチ位置に動かすので
カーソルも飛びません。指を動かすと二本の仮想の指が一緒に動き、パンになります。
短い二本指タッチは右クリック扱いされるため、小さなピンチは少し動いてから始めます。

## トラブルシューティング

```sh
systemctl --user status macpad-x11.service
journalctl --user -u macpad-x11.service
```

ボタンが押されたままになったように見えたら、
`systemctl --user restart macpad-x11.service` で解放されます。

## ライセンス

MIT
