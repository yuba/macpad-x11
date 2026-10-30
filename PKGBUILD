# Maintainer: yuba <m.takuma@gmail.com>
pkgname=macpad-x11
pkgver=0.6.0
pkgrel=1
pkgdesc="macOS-style touchpad gestures for X11: three-finger drag, pinch zoom around the pointer, four-finger desktop switching, show desktop and launcher, inertial scrolling"
arch=('any')
url="https://github.com/yuba/macpad-x11"
license=('MIT')
depends=('python>=3.8' 'libinput' 'libx11' 'libxtst' 'libxext' 'libxi' 'coreutils')
provides=('three-finger-drag')
conflicts=('three-finger-drag')
replaces=('three-finger-drag')
source=("$pkgname-$pkgver.tar.gz::$url/archive/refs/tags/v$pkgver.tar.gz")
sha256sums=('5a24d4f995c55b644344a63f3803a96722a2c4d9a305a17d6f0f635a17e8416e')
install=$pkgname.install

package() {
  cd "$pkgname-$pkgver"
  install -Dm755 $pkgname "$pkgdir/usr/bin/$pkgname"
  install -Dm644 apps.ini "$pkgdir/usr/share/$pkgname/apps.ini"
  install -Dm644 $pkgname.service "$pkgdir/usr/lib/systemd/user/$pkgname.service"
  install -Dm644 $pkgname.desktop "$pkgdir/etc/xdg/autostart/$pkgname.desktop"
  install -Dm644 config.example.ini "$pkgdir/usr/share/doc/$pkgname/config.example.ini"
  install -Dm644 README.md "$pkgdir/usr/share/doc/$pkgname/README.md"
  install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
