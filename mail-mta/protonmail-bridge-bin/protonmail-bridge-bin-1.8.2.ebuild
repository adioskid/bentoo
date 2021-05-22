# Distributed under the terms of the GNU General Public License v2
 
EAPI=7

inherit rpm xdg
 
DESCRIPTION="The Bridge is an application that runs on your computer in the background and seamlessly encrypts and decrypts your mail as it enters and leaves your computer."
HOMEPAGE="https://protonmail.com/bridge/"
SRC_URI="https://protonmail.com/download/bridge/protonmail-bridge-1.8.2-1.x86_64.rpm -> protonmail-bridge-bin-1.8.2.rpm"
 
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE=""
 
DEPEND=""
RDEPEND="${DEPEND}
	media-libs/libglvnd
	app-crypt/libsecret
    dev-qt/qtcore
	dev-qt/qtdeclarative
	dev-qt/qtmultimedia
	dev-qt/qtsvg
	dev-qt/qtquickcontrols
	dev-qt/qtquickcontrols2
	sys-libs/glibc
	dev-libs/glib
	media-fonts/dejavu
"
BDEPEND=""

S=${WORKDIR}/usr

src_install() {
  cp -pRP ${S} "${D}"
}