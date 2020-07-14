# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{7,8} )

inherit meson python-r1 vala xdg-utils versionator

MY_PV=$(get_version_component_range 1-2)

DESCRIPTION="GObject-based wrapper around the Exiv2 library"
HOMEPAGE="https://wiki.gnome.org/Projects/gexiv2"
SRC_URI="mirror://gnome/sources/${PN}/${MY_PV}/${P}.tar.xz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="gtk-doc +introspection python static-libs test +vala"

REQUIRED_USE="
	python? ( introspection ${PYTHON_REQUIRED_USE} )
	test? ( python introspection )
	vala? ( introspection )
"

RDEPEND="${PYTHON_DEPS}
	>=dev-libs/glib-2.62.2:2
	>=media-gfx/exiv2-0.21:0=
	introspection? ( >=dev-libs/gobject-introspection-1.62.0:= )"

DEPEND="${RDEPEND}
	virtual/pkgconfig
	gtk-doc? ( dev-util/gtk-doc )
	test? (
		dev-python/pygobject:3
		media-gfx/exiv2[xmp]
	)
	vala? ( $(vala_depend) )"

src_prepare() {
	xdg_environment_reset
	use vala && vala_src_prepare
	default
}

src_configure() {
	local emesonargs=(
		$(meson_use introspection)
		$(meson_use vala vapi)
		$(meson_use gtk-doc gtk_doc)
		# prevents installation of python modules (uses install_data from meson
		# which does not optimize the modules
		-Dpython2-girdir=no
		-Dpython3-girdir=no
	)

	meson_src_configure
}

src_install() {
	meson_src_install

	if use python ; then
		python_moduleinto gi/overrides/
		python_foreach_impl python_domodule GExiv2.py
	fi
}
