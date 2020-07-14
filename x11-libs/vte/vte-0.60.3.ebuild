# Distributed under the terms of the GNU General Public License v2

EAPI=7
VALA_USE_DEPEND="vapigen"

inherit autotools gnome3 meson vala

DESCRIPTION="Library providing a virtual terminal emulator widget"
HOMEPAGE="https://wiki.gnome.org/action/show/Apps/Terminal/VTE"
SRC_URI="https://gitlab.gnome.org/GNOME/vte/-/archive/${PV}/vte-${PV}.tar.gz"

LICENSE="LGPL-2+"
SLOT="2.91"
KEYWORDS="*"

IUSE="+crypt doc debug elogind glade +gtk3 gtk4 +introspection bidi +vala"
REQUIRED_USE="vala? ( introspection )"

RDEPEND="
	>=dev-libs/glib-2.62.2:2
	>=dev-libs/libpcre2-10.21
	gtk3? ( >=x11-libs/gtk+-3.24.12:3[introspection?] )
	gtk4? ( >=x11-libs/gtk-3.96.0:0[introspection?] )
	>=x11-libs/pango-1.44.7

	sys-libs/ncurses:0=
	sys-libs/zlib

	elogind? ( >=sys-auth/elogind-241.3 )
	!elogind? ( >=sys-apps/systemd-220 )

	crypt?  ( >=net-libs/gnutls-3.2.7:0= )
	glade? ( >=dev-util/glade-3.9:3.10 )
	introspection? ( >=dev-libs/gobject-introspection-1.62.0:= )
"
DEPEND="${RDEPEND}
	dev-util/gperf
	dev-libs/libxml2
	dev-util/gtk-doc
	>=dev-util/gtk-doc-am-1.13
	>=dev-util/intltool-0.35
	sys-devel/gettext
	virtual/pkgconfig

	vala? ( $(vala_depend) )
"
RDEPEND="${RDEPEND}
	!x11-libs/vte:2.90[glade]
"

src_prepare() {
	sed -i -e "s/4.0.0/3.96.0/" meson.build
	sed -i -e "s/gtk+-4.0/gtk4/" meson.build

	use vala && vala_src_prepare

	eapply "${FILESDIR}"/${PN}-0.60.0-elogind-support.patch

	gnome3_src_prepare
}

src_configure() {
	local emesonargs=(
		$(meson_use debug debugg)
		$(meson_use doc docs)
		$(meson_use introspection gir)
		$(meson_use bidi fribidi)
		$(meson_use crypt gnutls)
		$(meson_use gtk3)
		$(meson_use gtk4)
		$(meson_use elogind)
		-Dicu=true
		$(meson_use vala vapi)
	)

	meson_src_configure
}

src_install() {
	meson_src_install
	mv "${ED}"/etc/profile.d/vte{,-${SLOT}}.sh || die
}
