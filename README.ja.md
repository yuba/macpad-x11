<p align="center"><img src="art/icon.svg" width="128" alt="macpad-x11 icon"></p>

# macpad-x11

X11 上の Linux タッチパッドで、macOS のようなジェスチャーを実現します。

[English](README.md)

- **三本指ドラッグ。** 三本指スワイプでウィンドウ・ファイル・テキスト選択をドラッグ。
  指を一瞬離してもう一度置けば**同じドラッグを続けられます**（Mac と同じ）。
  一本指でポインターを動かす・クリック・スクロールすれば即座に終わります。
- **ポインターを中心にしたピンチズーム。** ズーム中もポインターの下の場所が動かず、
  ピンチしながら指を動かせばパンもできます。Chrome などの Chromium / Electron アプリでは、
  X11 版 Chrome がタッチパッドのピンチを無視するにもかかわらず、ネイティブの滑らかなズームになります。
  その他のアプリはホイールやキーで操作します。どれを使うかは [apps.ini](apps.ini) に書かれていて、
  コードに触れずに自分でアプリを追加できます。
- **四本指スワイプでデスクトップ切り替え。** 四本指で左右にスワイプすると、左右隣のデスクトップに移ります。
  スワイプ中はデスクトップの一覧が小さく表示され、ハイライトが指に追従します。半分を過ぎてから指を離すと切り替わります。
  EWMH のデスクトップに対応したウィンドウマネージャー（Xfwm4、KWin、Mutter、Openbox、i3 など）で動きます。
- **四本指ピンチでデスクトップ表示とランチャー。** 親指と三本の指を広げると全ウィンドウを隠してデスクトップを表示し、
  つまむとウィンドウを元に戻します。ウィンドウが出ているときにつまむと、デスクトップ環境のランチャーを開きます
  （送るキーやシェルコマンドは自由に設定できます）。画面中央の4つの円が指に合わせて集まったり広がったりし、
  十分にピンチすると塗りつぶされた黄色に変わります。
- **慣性スクロール。** 二本指で弾くようにスクロールして指を離すと、Mac のようにページが滑り続け、だんだん減速します。
  タッチパッドに触れれば止まり、そのタッチはクリックになりません。X11 では指を離した瞬間に止まってしまう
  Chrome などの Chromium 系ブラウザー、VS Code、Zed で有効です。Evince などの GTK 3 アプリは
  自分で慣性スクロールするので手を出しません。
- Python スクリプト 1 本。コンパイル不要、root デーモン不要、fusuma や touchegg も不要

macpad-x11 は、ピンチを覚える前は three-finger-drag という名前でした。

## 動作要件

- **X11** セッション（Wayland 非対応）
- Python 3.8 以降（標準ライブラリのみ使用）
- `libinput`（`libinput debug-events` コマンド。Debian/Ubuntu では `libinput-tools` パッケージ）
- `libX11`、`libXtst`、`libXext`、`libXi`（Arch: `libx11 libxtst libxext libxi` / Debian・Ubuntu: `libx11-6 libxtst6 libxext6 libxi6` / Fedora: `libX11 libXtst libXext libXi`）
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

インストールが終われば、clone したディレクトリは不要で、削除しても構いません。パッケージは `/usr` に入り、
アンインストールも pacman だけでできます。更新するときは、clone したディレクトリで `git pull` してから
（削除していれば clone し直してから）、もう一度 `makepkg -si` を実行します。

### Debian / Ubuntu

[最新リリース](https://github.com/yuba/macpad-x11/releases/latest) から `macpad-x11_*_all.deb` をダウンロードして:

```sh
sudo apt install ./macpad-x11_*_all.deb
systemctl --user start macpad-x11.service   # またはログインし直す
```

Debian 12 以降、Ubuntu 20.04 以降に対応しています。アンインストールは `sudo apt remove macpad-x11` です。

### Fedora

[最新リリース](https://github.com/yuba/macpad-x11/releases/latest) から `macpad-x11-*.noarch.rpm` をダウンロードして:

```sh
sudo dnf install ./macpad-x11-*.noarch.rpm
systemctl --user start macpad-x11.service   # またはログインし直す
```

アンインストールは `sudo dnf remove macpad-x11` です。

### その他のディストリビューション

```sh
git clone https://github.com/yuba/macpad-x11.git
cd macpad-x11
./install.sh
```

`~/.local` へのインストール、systemd ユーザーサービスと XDG autostart の登録、
デーモンの起動までを行います。root 権限は不要です。アンインストールは:

```sh
./install.sh --uninstall
```

install.sh はファイルをコピーするので、clone したディレクトリを削除しても macpad-x11 は動き続けます。
ただし、できれば残しておいてください。更新（`git pull && ./install.sh`）もアンインストールも
clone したディレクトリから実行するため、削除した場合は先に clone し直す必要があります。
`~/.config/macpad-x11` の設定ファイルは、どの操作でも変更されません。

## 設定

`~/.config/macpad-x11/config.ini`。すべての項目は省略可能です。全項目は
[config.example.ini](config.example.ini) を参照してください。

```ini
[drag]
timeout = 0.5      # 指を離した後の猶予時間（秒）
speed = 3.0        # スワイプ量に対するポインター移動量の倍率

[pinch]
enabled = yes

[inertia]
decay = 0.4        # 慣性スクロールの減速の速さ（秒）

[app Some-app]     # WM_CLASS のクラス名またはインスタンス名。apps.ini より優先
zoom = wheel
modifier = ctrl
step = 1.1
pan = wheel
inertia = yes      # 二本指スクロールの後に慣性で滑らせる
```

変更は `systemctl --user reload macpad-x11.service` で反映されます。

## ピンチズームと apps.ini

ポインターを中心にズームさせる方法はアプリごとに違うため、[apps.ini](apps.ini) に
WM_CLASS ごとに、いくつかの汎用的な方式のどれを使うかを書いてあります。

| `zoom`  | macpad-x11 が送るもの                                          | 向いているアプリ                     |
|---------|----------------------------------------------------------------|--------------------------------------|
| `touch` | 仮想タッチスクリーン上の二本指ピンチ（一本はポインター上に固定） | Chromium、Electron、一部の GTK アプリ。滑らかでパンも可 |
| `wheel` | `modifier` を押しながらのポインター位置でのホイール             | （Ctrl+）ホイールでポインター中心にズームするアプリ |
| `keys`  | `zoom_in` / `zoom_out` のキー入力                               | 最後の手段。アプリ自身の中心でズーム |
| `none`  | 何もしない                                                     | 自前でピンチを処理するアプリ         |

`wheel` と `keys` では、`step` はアプリ側の 1 クリック（1 打鍵）あたりの倍率で、
`pan = wheel` を指定するとピンチ中の指の移動をホイールでのパンに変換します。
載っていないアプリには `[pinch.default]`（`zoom = keys`）が使われます。

`[app 名前]` のセクションは WM_CLASS の両方の部分（クラス名とインスタンス名）に、大文字・小文字を区別せずに照合され、
名前にはワイルドカードも使えます。たとえば `[app vivaldi*]` はネイティブ版と Flatpak 版の両方に一致します。
`requires_env = NAME=VALUE` を持つセクションは、その環境変数を持つプロセスにだけ適用されます。

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
| mpv | 段階的（`wheel`）、中心が少しずれる | なし |
| zathura | ズームはするが表示領域の中心が基準（`wheel`） | なし |

**Firefox** は、環境変数 `MOZ_USE_XINPUT2=1` を付けて起動したときだけタッチスクリーンのピンチを扱います。
`~/.xprofile` に `export MOZ_USE_XINPUT2=1` と書くなどして設定してください。macpad-x11 は Firefox の
プロセスごとにこの変数を確かめ（項目の `requires_env`）、付けずに起動された Firefox にはキー入力を使います。

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
内容がどれだけずれたかを測って、設定ファイルや apps.ini に貼れる設定を出力します。
歓迎画面などのダイアログは先に閉じ、比較画像も目で確認してください。模様の少ない文書だと計測を誤ることがあります。
タッチスクリーンのピンチでズームしないアプリには、決して `zoom = touch` を設定しないでください。
X が仮想の指をマウスのドラッグとして扱ってしまいます。
アプリを追加するプルリクエストを歓迎します。比較画像 `probe.png` を添付してください。

## 慣性スクロール

X11 には指がタッチパッドから離れたことをアプリに伝える仕組みがないため、ほとんどのアプリは指を離した瞬間にスクロールが止まります。
GTK 3 アプリはイベントの途切れから推測して自分で慣性スクロールします。それ以外のアプリのために、
macpad-x11 は素早い二本指スクロールの後、指の速さで仮想ホイールを回し続け、止まるまで減速させます。

対象のアプリは [apps.ini](apps.ini) の `inertia = yes` で決まります（Chrome、Chromium、Brave、Edge、Vivaldi、
VS Code（Code、code-oss、VSCodium、Cursor）、Zed）。config.ini の `[app ...]` セクションに `inertia = yes` と書けば
他のアプリにも付けられますが、自分で慣性スクロールするアプリには付けないでください。二重に滑ります。
`[pinch.default]` に `inertia = yes` と書くと、一覧にないすべてのアプリが対象になります。

タッチパッドに触れる、クリックする、キーを押す、ポインターを動かす、修飾キーを押す（ホイールがズームに化けるため）と止まります。
滑っている間はタップを無効にしているので、止めるためのタップはクリックになりません。
ナチュラルスクロールの設定と、タッチパッドの "Scrolling Pixel Distance"（xorg.conf の `ScrollPixelDistance`）に従います。

config.ini の `[inertia]`: `decay` は速度が約 3 分の 1 に落ちるまでの秒数（既定値 0.4）、`speed` は滑り出しの速度の倍率（1.0）、
`min_speed` はこれより遅いと滑り出さない・止まる速度で、タッチパッドのピクセル毎秒です（100）。

既知の問題: Chrome では、指によるスクロールと慣性の間でページが一瞬止まります。Chrome がこの二つを
別のデバイスからの別々のスクロールとして扱うためです。Zed と VS Code では途切れずに滑ります。

## 競合

fusuma、touchegg、libinput-gestures、デスクトップ環境自身のジェスチャーなどで
三本指・四本指スワイプや二本指・四本指ピンチに割り当てがあれば無効にしてください。同じジェスチャーに両方が反応します。
macpad-x11 の各機能は、config.ini のそれぞれのセクションで `enabled = no` にすれば止められます。

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

**スワイプ。** 四本指の `GESTURE_SWIPE_BEGIN` で、ルートウィンドウからデスクトップの数・現在のデスクトップ・並び
（`_NET_NUMBER_OF_DESKTOPS`、`_NET_CURRENT_DESKTOP`、`_NET_DESKTOP_LAYOUT`）を読みます。
指が動いている間は、クリックを透過する override-redirect ウィンドウにデスクトップを並べて描きます
（コンポジターが動いていれば半透明）。`distance` の半分を過ぎて指を離すと、EWMH の
`_NET_CURRENT_DESKTOP` クライアントメッセージでウィンドウマネージャーに隣のデスクトップへの切り替えを頼みます。
デスクトップ自体が指に合わせて滑ることはありません。X11 では表示していないデスクトップの画面が得られないためです。

**四本指ピンチ。** デスクトップの表示と復帰には EWMH の `_NET_SHOWING_DESKTOP` を使い、macpad-x11 自身は状態を持ちません。
ウィンドウマネージャーがまだデスクトップを表示しているときにつまめばウィンドウを戻し、そうでなければランチャーを開きます
（ウィンドウが現れると、ウィンドウマネージャーは自分でデスクトップ表示を解除します）。ランチャーのコマンドは
`sh -c` で、独立したセッションとして実行します。libinput はピンチの指を最大4本として報告するので、五本指のピンチは四本指として扱われます。

**慣性。** libinput は指が離れると二本指スクロールを "scroll stop" イベントで終えます。直前 60ms のスクロールイベントから
指がまだ動いていたと分かり、ポインターの下のウィンドウが `inertia = yes` のアプリなら、uinput の仮想マウスが
高解像度ホイールを毎秒 120 回、指数関数的に減速しながら回します。ピクセル距離とナチュラルスクロールの設定は
タッチパッドの XInput プロパティから読みます。libinput は置いたままの指を報告しないので、タッチパッドのイベントデバイスも
読んで `BTN_TOUCH` で即座に止めます。滑っている間は "libinput Tapping Enabled" を切り、最後の指が離れて 0.1 秒後に戻します。
その間にデーモンが落ちても、`$XDG_RUNTIME_DIR` の目印ファイルで次回起動時に元に戻します。

## トラブルシューティング

```sh
systemctl --user status macpad-x11.service
journalctl --user -u macpad-x11.service
```

ボタンが押されたままになったように見えたら、
`systemctl --user restart macpad-x11.service` で解放されます。タップが無効のまま戻らないときも同じです。

## ライセンス

MIT
