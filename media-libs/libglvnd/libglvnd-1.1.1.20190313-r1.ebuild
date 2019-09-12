# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6


PYTHON_COMPAT=( python2_7 )

inherit autotools multilib-minimal python-any-r1

DESCRIPTION="The GL Vendor-Neutral Dispatch library"
HOMEPAGE="https://github.com/NVIDIA/libglvnd"
EGIT_REPO_URI="${HOMEPAGE}.git"
SRC_URI="${HOMEPAGE}/releases/download/v${PV}/${P}.tar.gz"

PV_L=${PV##*.}
if [ ${PV_L} -gt 9000 ] ; then
	inherit git-r3
	if [ ${PV_L} -gt 19000101 ] ; then
		CD_YYYY="${PV_L%????}"
		CD_DD="${PV_L#??????}"
		CD_MM="${PV_L#${CD_YYYY}}"
		CD_MM="${CD_MM%${CD_DD}}"

		EGIT_COMMIT_DATE="${CD_YYYY}-${CD_MM}-${CD_DD}"
		KEYWORDS="*"
	fi
	SRC_URI=""
else
	KEYWORDS="*"
	EGIT_REPO_URI=""
fi

KEYWORDS="*"
LICENSE="MIT"
SLOT="0"
IUSE="+asm +glx +gles +egl debug"

RDEPEND="
	x11-libs/libX11[${MULTILIB_USEDEP}]
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

src_unpack() {
	default
	[ -n "${EGIT_REPO_URI}" ] && git-r3_src_unpack
}

src_prepare() {
	default
	eautoreconf
}

multilib_src_configure() {
	ECONF_SOURCE=${S} econf $(usex debug "--enable-debug" "") $(usex asm "" "--disable-asm") $(usex glx "" "--disable-glx") $(usex gles "" "--disable-gles") $(usex egl "" "--disable-egl")
}

multilib_src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}

multilib_src_test() {
	emake check
}

