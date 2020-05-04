# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
GNOME2_LA_PUNT="yes"
PYTHON_COMPAT=( python3_{6,7} )
VALA_MIN_API_VERSION=${VALA_MIN_API_VERSION:-0.44}
VALA_USE_DEPEND="vapigen"

inherit gnome2 multibuild python-r1 vala meson

DESCRIPTION="VNC viewer widget for GTK"
HOMEPAGE="https://wiki.gnome.org/Projects/gtk-vnc"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="+introspection"

# libview is used in examples/gvncviewer -- no need
# glib-2.30.1 needed to avoid linking failure due to .la files (bug #399129)
COMMON_DEPEND="
	>=dev-libs/glib-2.62.2:2
	>=dev-libs/libgcrypt-1.4.2:0=
	dev-libs/libgpg-error
	>=net-libs/gnutls-3.0:0=
	>=x11-libs/cairo-1.16.0
	>=x11-libs/gtk+-2.18:2
	x11-libs/libX11
	>=x11-libs/gtk+-2.91.3:3[introspection?]
	>=dev-libs/gobject-introspection-1.62.0
	media-sound/pulseaudio
	${PYTHON_DEPS}
	>=dev-python/pygobject-3:3[${PYTHON_USEDEP}]
	dev-libs/cyrus-sasl
"
RDEPEND="${COMMON_DEPEND}"

DEPEND="${COMMON_DEPEND}
	>=dev-lang/perl-5
	>=dev-util/intltool-0.40
	sys-devel/gettext
	virtual/pkgconfig
	$(vala_depend)
	>=dev-libs/gobject-introspection-1.62.0
"
# eautoreconf requires gnome-common

src_prepare() {
	vala_src_prepare
	gnome2_src_prepare
}

src_configure() {
	local emesonargs=(
		-Dwith-coroutine=gthread
	)

	meson_src_configure
}

src_compile() {
	meson_src_compile
}

src_install() {
	meson_src_install
}
