# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6


PYTHON_COMPAT=( python2_7 )

inherit autotools python-any-r1

DESCRIPTION="The GL Vendor-Neutral Dispatch library"
HOMEPAGE="https://github.com/NVIDIA/libglvnd"
EGIT_REPO_URI="${HOMEPAGE}.git"
SRC_URI="${HOMEPAGE}/releases/download/v${PV}/${P}.tar.gz"

KEYWORDS="*"
LICENSE="MIT"
SLOT="0"
IUSE="+asm +glx +gles +egl debug"

GITHUB_REPO="$PN"
GITHUB_USER="NVIDIA"
GITHUB_TAG="v1.1.1"
SRC_URI="https://www.github.com/${GITHUB_USER}/${GITHUB_REPO}/tarball/${GITHUB_TAG} -> ${PN}-${GITHUB_TAG}.tar.gz"

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}/${GITHUB_USER}-${PN}"-??????? "${S}" || die
}

RDEPEND="
	x11-libs/libX11
	x11-proto/glproto
	x11-libs/libXext
"

DEPEND="
	${PYTHON_DEPS}
	${RDEPEND}
"

RDEPEND="
	${RDEPEND}
	!media-libs/mesa[-glvnd(-)]
"

PATCHES=(
	"$FILESDIR"/0001-Add-pkgconfig-data-for-libraries-implemented-so-far.patch
)

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	ECONF_SOURCE=${S} econf $(usex debug "--enable-debug" "") $(usex asm "" "--disable-asm") $(usex glx "" "--disable-glx") $(usex gles "" "--disable-gles") $(usex egl "" "--disable-egl")
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
