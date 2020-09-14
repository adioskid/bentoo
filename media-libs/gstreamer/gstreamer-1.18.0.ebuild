# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit bash-completion-r1 meson pax-utils

DESCRIPTION="Open source multimedia framework"
HOMEPAGE="https://gstreamer.freedesktop.org/"
SRC_URI="https://${PN}.freedesktop.org/src/${PN}/${P}.tar.xz"

LICENSE="LGPL-2+"
SLOT="1.0"
KEYWORDS="~alpha amd64 arm arm64 ~hppa ~ia64 ~mips ppc ppc64 ~sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="bash-completion +caps +introspection nls +orc test unwind valgrind"
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

	local emesonargs=(
		-Dbash-completion=$(usex bash-completion enabled disabled)
		-Dintrospection=$(usex introspection enabled disabled)
		-Dlibunwind=$(usex unwind enabled disabled)
		-Dlibdw=$(usex unwind enabled disabled)
		-Dnls=$(usex nls auto false)
		-Dtests=$(usex test enabled disabled)
		-Dvalgrind=$(usex valgrind auto false)
	)

	if use caps ; then
		myconf+=( --with-ptp-helper-permissions=capabilities )
	else
		myconf+=(
			--with-ptp-helper-permissions=setuid-root
			--with-ptp-helper-setuid-user=nobody
			--with-ptp-helper-setuid-group=nobody
		)
	fi

  meson_src_configure
}

src_compile() {
	meson_src_compile
}

src_install() {
	meson_src_install
	
	# Needed for orc-using gst plugins on hardened/PaX systems, bug #421579
	use orc && pax-mark -m "${ED}usr/$(get_libdir)/gstreamer-${SLOT}/gst-plugin-scanner"
}

multilib_src_install_all() {
	DOCS="AUTHORS ChangeLog NEWS MAINTAINERS README RELEASE"
	einstalldocs
	find "${ED}" -name '*.la' -delete || die

	# Needed for orc-using gst plugins on hardened/PaX systems, bug #421579
	use orc && pax-mark -m "${ED}usr/bin/gst-launch-${SLOT}"
}