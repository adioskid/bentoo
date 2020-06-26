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
	KEYWORDS="*"
	SRC_URI="https://gitlab.freedesktop.org/glvnd/${PN}/-/archive/v${PV}/${PN}-v${PV}.tar.bz2 -> ${P}.tar.bz2"
	S=${WORKDIR}/${PN}-v${PV}
fi

LICENSE="MIT"
SLOT="0"
IUSE="+asm +egl +gles +gles2 +glx +headers test tls +X"
RESTRICT="!test? ( test )"

BDEPEND="${PYTHON_DEPS}
	test? ( X? ( ${VIRTUALX_DEPEND} ) )"
RDEPEND="
	!media-libs/mesa[-glvnd(-)]
	!<media-libs/mesa-19.2.2
	X? (
		x11-libs/libX11
		x11-libs/libXext
		x11-proto/glproto
	)"
DEPEND="${RDEPEND}
	X? ( x11-base/xorg-proto )"

src_prepare() {
	default
	sed -i -e "/^PLATFORM_SYMBOLS/a \    '__gentoo_check_ldflags__'," \
		bin/symbols-check.py || die
}

src_configure() {
	local emesonargs=(
		-Dasm=$(usex asm enabled disabled)
		-Degl=$(usex egl true false)
		-Dgles1=$(usex gles true false)
		-Dgles2=$(usex gles2 true false)
		-Dglx=$(usex glx enabled disabled)
		-Dheaders=$(usex headers true false)
		-Dtls=$(usex tls enabled disabled)
		-Dx11=$(usex X enabled disabled)
	)
	use elibc_musl && emesonargs+=( -Dtls=disabled )

	meson_src_configure
}

src_compile() {
	meson_src_compile
}

src_test() {
	if use X; then
		virtx meson_src_test
	else
		meson_src_test
	fi
}

src_install() {
	meson_src_install
}
