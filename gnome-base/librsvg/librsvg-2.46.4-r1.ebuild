# Distributed under the terms of the GNU General Public License v2

EAPI=6
VALA_USE_DEPEND="vapigen"
inherit autotools eutils gnome3 vala

DESCRIPTION="Scalable Vector Graphics (SVG) rendering library"
HOMEPAGE="https://wiki.gnome.org/Projects/LibRsvg"

LICENSE="LGPL-2"
SLOT="2"
KEYWORDS="*"

IUSE="+introspection tools vala"

RDEPEND="
	>=dev-libs/glib-2.62.2:2
	>=x11-libs/cairo-1.16.0
	>=x11-libs/pango-1.44.7
	>=dev-libs/libxml2-2.9.1:2
	>=dev-libs/libcroco-0.6.8
	>=x11-libs/gdk-pixbuf-2.39.2:2[introspection?]
	>=virtual/rust-1.34
	introspection? ( >=dev-libs/gobject-introspection-1.62.0:= )
"
DEPEND="${RDEPEND}
	dev-libs/gobject-introspection-common
	dev-libs/vala-common
	>=dev-util/gtk-doc-am-1.13
	vala? ( $(vala_depend) )
	>=virtual/pkgconfig-0-r1
"

src_prepare() {
	local build_dir

	eautoreconf
	gnome3_src_prepare
	use vala && vala_src_prepare
}

src_configure() {

	ECONF_SOURCE=${S} econf \
		--disable-static \
		$(use_enable introspection) \
		$(use_enable tools) \
		$(use_enable vala) \
		--enable-pixbuf-loader
	ln -s "${S}"/doc/html doc/html || die
}

src_compile() {
	# causes segfault if set, see bug #411765
	unset __GL_NO_DSO_FINALIZER
}

pkg_postinst() {
	# causes segfault if set, see bug 375615
	unset __GL_NO_DSO_FINALIZER
	gnome3_pkg_postinst
}

pkg_postrm() {
	# causes segfault if set, see bug 375615
	unset __GL_NO_DSO_FINALIZER
	gnome3_pkg_postrm
}
