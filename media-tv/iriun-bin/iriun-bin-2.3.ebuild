# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop eutils readme.gentoo-r1 xdg

MY_PN="iriunwebcam"

DESCRIPTION="Use android phone as webcam, using a v4l device driver and app"
HOMEPAGE="https://www.dev47apps.com/"
SRC_URI="https://iriun.gitlab.io/${MY_PN}.deb -> ${MY_PN}.deb"

KEYWORDS="*"
LICENSE="GPL-2"
SLOT="0"

IUSE="qt5"

DEPEND="
	dev-qt/qtcore
	media-tv/v4l-utils
	media-video/obs-v4l2sink
	media-video/v4l2loopback
"

BDEPEND="${DEPEND}"

S="${WORKDIR}"

src_unpack(){
	unpack "${A}"
	unpack ./data.tar.xz
	rm *.tar.xz debian-binary
}

src_install(){
	insinto /etc/modprobe.d
	doins etc/modprobe.d/*  || die

	insinto /usr/local/bin
	doins usr/local/bin/${MY_PN}
	fperms +x "/usr/local/bin/${MY_PN}"

	newicon usr/share/pixmaps/${MY_PN}.png ${MY_PN}.png
	domenu usr/share/applications/${MY_PN}.desktop
}

pkg_postinst() {
	modprobe v4l2loopback
}