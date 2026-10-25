# Maintainer: yuba <m.takuma@gmail.com>
pkgname=macpad-x11
pkgver=0.2.1
pkgrel=1
pkgdesc="macOS-style touchpad gestures for X11: three-finger drag and pinch zoom around the pointer"
arch=('any')
url="https://github.com/yuba/macpad-x11"
license=('MIT')
depends=('python>=3.11' 'libinput' 'libx11' 'libxtst' 'coreutils')
provides=('three-finger-drag')
conflicts=('three-finger-drag')
replaces=('three-finger-drag')
source=("$pkgname-$pkgver.tar.gz::$url/archive/refs/tags/v$pkgver.tar.gz")
# Pinned in a follow-up commit once the tag exists (updpkgsums).
sha256sums=('SKIP')
install=$pkgname.install

package() {
  cd "$pkgname-$pkgver"
  install -Dm755 $pkgname "$pkgdir/usr/bin/$pkgname"
  install -Dm644 apps.toml "$pkgdir/usr/share/$pkgname/apps.toml"
  install -Dm644 $pkgname.service "$pkgdir/usr/lib/systemd/user/$pkgname.service"
  install -Dm644 $pkgname.desktop "$pkgdir/etc/xdg/autostart/$pkgname.desktop"
  install -Dm644 config.example.toml "$pkgdir/usr/share/doc/$pkgname/config.example.toml"
  install -Dm644 README.md "$pkgdir/usr/share/doc/$pkgname/README.md"
  install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
