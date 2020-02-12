# Copyright 2018-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGIT_REPO_URI="https://gitlab.freedesktop.org/glvnd/libglvnd.git"

if [[ ${PV} = 9999* ]]; then
	GIT_ECLASS="git-r3"
fi

PYTHON_COMPAT=( python3_{6,7,8} )
VIRTUALX_REQUIRED=manual

inherit ${GIT_ECLASS} meson python-any-r1 virtualx

DESCRIPTION="The GL Vendor-Neutral Dispatch library"
HOMEPAGE="https://gitlab.freedesktop.org/glvnd/libglvnd"
if [[ ${PV} = 9999* ]]; then
	SRC_URI=""
else
	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~riscv ~sparc ~x86"
	SRC_URI="https://gitlab.freedesktop.org/glvnd/${PN}/-/archive/v${PV}/${PN}-v${PV}.tar.bz2 -> ${P}.tar.bz2"
	S=${WORKDIR}/${PN}-v${PV}
fi

LICENSE="MIT"
SLOT="0"
IUSE="+asm +egl +gles +gles2 +glx +headers tls +X"
RESTRICT=""

BDEPEND="${PYTHON_DEPS}"
RDEPEND="
	!media-libs/mesa[-glvnd(-)]
	!<media-libs/mesa-19.2.2
	X? (
		x11-libs/libX11
		x11-libs/libXext
		x11-proto/glproto
	)"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}"/${P}-meson-Fix-the-armv7-build.patch
	"${FILESDIR}"/${P}-meson-Fix-the-PPC64-build.patch
	"${FILESDIR}"/${P}-tests-Add-_GLOBAL_OFFSET_TABLE_-to-PLATFORM_SYMBOLS.patch
)

src_configure() {
	local emesonargs=(
		-Dasm=$(usex asm enabled disabled)
		-Dglx=$(usex glx enabled disabled)
		-Degl=$(usex egl true false)
		-Dgles1=$(usex gles true false)
		-Dgles2=$(usex gles2 true false)
		-Dheaders=$(usex headers true false)
		-Dtls=$(usex tls enabled disabled)
		-Dx11=$(usex X enabled disabled)
	)
	meson_src_configure
}

src_compile() {
	meson_src_compile
}

src_install() {
	meson_src_install
}
