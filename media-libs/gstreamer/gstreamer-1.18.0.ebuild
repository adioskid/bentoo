# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit bash-completion-r1 meson pax-utils

DESCRIPTION="Open source multimedia framework"
HOMEPAGE="https://gstreamer.freedesktop.org/"
SRC_URI="https://${PN}.freedesktop.org/src/${PN}/${P}.tar.xz"

LICENSE="LGPL-2+"
SLOT="1.0"
KEYWORDS="~alpha amd64 arm arm64 ~hppa ~ia64 ~mips ppc ppc64 ~sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="+caps +introspection nls +orc test unwind valgrind"
RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-util/meson-0.54.2
	>=dev-libs/glib-2.44.0
	caps? ( sys-libs/libcap )
	introspection? ( >=dev-libs/gobject-introspection-1.31.1:= )
	unwind? (
		>=sys-libs/libunwind-1.2_rc1
		dev-libs/elfutils
	)
	!<media-libs/gst-plugins-bad-1.13.1:1.0
	valgrind? ( dev-util/valgrind )
"
DEPEND="${RDEPEND}
	dev-util/glib-utils
	>=dev-util/gtk-doc-am-1.12
	sys-devel/bison
	sys-devel/flex
	virtual/pkgconfig
	nls? ( sys-devel/gettext )
"

src_configure() {

	if [[ ${CHOST} == *-interix* ]] ; then
		export ac_cv_lib_dl_dladdr=no
		export ac_cv_func_poll=no
	fi
	if [[ ${CHOST} == powerpc-apple-darwin* ]] ; then
		# GCC groks this, but then refers to an implementation (___multi3,
		# ___udivti3) that don't exist (at least I can't find it), so force
		# this one to be off, such that we use 2x64bit emulation code.
		export gst_cv_uint128_t=no
	fi

	local completiondir=$(get_bashcompdir)

	local emesonargs=(
		-Dlibunwind=$(usex unwind enabled disabled)
		-Dlibdw=$(usex unwind enabled disabled)
		-Dtests=$(usex test enabled disabled)
		-Dvalgrind=$(usex valgrind auto false)
		$(meson_use introspection enabled)
		$(meson_use nls auto)
		#$(meson_use check enabled)
		#$(meson_use benchmarks disabled)
		#$(meson_use gst_debug disabled)
		#$(meson_use examples disabled)
		
	)
  meson_src_configure
}

src_compile() {
	meson_src_compile
}

src_install() {
	meson_src_install
}

multilib_src_install_all() {
	einstalldocs
}