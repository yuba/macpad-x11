# Maintainer: yuba <m.takuma@gmail.com>
pkgname=three-finger-drag
pkgver=0.1.0
pkgrel=1
pkgdesc="macOS-style three-finger drag for X11 touchpads"
arch=('any')
url="https://github.com/yuba/three-finger-drag"
license=('MIT')
depends=('python>=3.11' 'libinput' 'libxtst' 'coreutils')
source=("$pkgname-$pkgver.tar.gz::$url/archive/refs/tags/v$pkgver.tar.gz")
sha256sums=('SKIP')
install=$pkgname.install

package() {
  cd "$pkgname-$pkgver"
  install -Dm755 $pkgname "$pkgdir/usr/bin/$pkgname"
  install -Dm644 $pkgname.service "$pkgdir/usr/lib/systemd/user/$pkgname.service"
  install -Dm644 $pkgname.desktop "$pkgdir/etc/xdg/autostart/$pkgname.desktop"
  install -Dm644 config.example.toml "$pkgdir/usr/share/doc/$pkgname/config.example.toml"
  install -Dm644 README.md "$pkgdir/usr/share/doc/$pkgname/README.md"
  install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
