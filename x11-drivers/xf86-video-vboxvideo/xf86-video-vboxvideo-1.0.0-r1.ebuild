# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools linux-info flag-o-matic 

DESCRIPTION="Driver for xorg-server"
KEYWORDS="*"
IUSE=" "
SRC_URI="https://gitlab.freedesktop.org/xorg/driver/xf86-video-vbox/-/archive/4f3a2bea254ebebcca4328bc780ce6b8f08dddfa/xf86-video-vbox-4f3a2bea254ebebcca4328bc780ce6b8f08dddfa.tar.bz2 -> xf86-video-vboxvideo-${PV}.tar.bz2"
SLOT="0"
S="$WORKDIR/xf86-video-vboxvideo-${PV}"

DEPEND="
	x11-base/xorg-proto
	x11-base/xorg-server
	>=sys-devel/libtool-2.2.6a
	sys-devel/m4
	>=x11-misc/util-macros-1.18
"

RDEPEND="
	${DEPEND}x11-libs/libpciaccess
	x11-libs/libXcomposite
"

WANT_AUTOCONF="latest"
WANT_AUTOMAKE="latest"
AUTOTOOLS_AUTORECONF="1"

pkg_setup() {
	append-ldflags -Wl,-z,lazy
}
src_prepare() {
	eautoreconf || die
	default
}


src_install() {
	default
	find "${D}" -type f -name '*.la' -delete || die
}
