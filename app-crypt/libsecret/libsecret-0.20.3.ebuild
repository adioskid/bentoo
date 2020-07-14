# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_COMPAT=( python3_{7,8} )
VALA_USE_DEPEND=vapigen

inherit gnome2 python-any-r1 vala virtualx

DESCRIPTION="GObject library for accessing the freedesktop.org Secret Service API"
HOMEPAGE="https://wiki.gnome.org/Projects/Libsecret"

LICENSE="LGPL-2.1+ Apache-2.0" # Apache-2.0 license is used for tests only
SLOT="0"

IUSE="+crypt +freedesktop-secret-service +introspection test +vala"
# Tests fail with USE=-introspection, https://bugs.gentoo.org/655482
REQUIRED_USE="vala? ( introspection )
	test? ( introspection )"

KEYWORDS="*"

RDEPEND="
	>=dev-libs/glib-2.62.2:2
	crypt? ( >=dev-libs/libgcrypt-1.2.2:0= )
	introspection? ( >=dev-libs/gobject-introspection-1.62.0:= )
"

# See https://bugs.gentoo.org/475182#c2 and https://bugs.gentoo.org/547456.
# Gentoo has libsecret hard depend on a freedesktop secret service, in this case gnome-keyring.
# We change this to have a configurable USE freedesktop-secret-service which can be met by
# any freedesktop.org secret service API compatible program, e.g. gnome-keyring or keepassx.
PDEPEND="
	freedesktop-secret-service? (
		|| (
			>=gnome-base/gnome-keyring-3
			app-admin/keepassxc
		)
	)
"

DEPEND="${RDEPEND}
	dev-libs/libxslt
	dev-util/gdbus-codegen
	>=dev-util/gtk-doc-am-1.9
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	test? (
		$(python_gen_any_dep '
			dev-python/mock[${PYTHON_USEDEP}]
			dev-python/dbus-python[${PYTHON_USEDEP}]
			introspection? ( dev-python/pygobject:3[${PYTHON_USEDEP}] )')
		introspection? ( >=dev-libs/gjs-1.32 )
	)
	vala? ( $(vala_depend) )
"

python_check_deps() {
	if use introspection; then
		has_version --host-root "dev-python/pygobject:3[${PYTHON_USEDEP}]" || return
	fi
	has_version --host-root "dev-python/mock[${PYTHON_USEDEP}]" &&
	has_version --host-root "dev-python/dbus-python[${PYTHON_USEDEP}]"
}

pkg_setup() {
	use test && python-any-r1_pkg_setup
}

src_prepare() {
	use vala && vala_src_prepare
	gnome2_src_prepare

	# Drop unwanted CFLAGS modifications
	sed -e 's/CFLAGS="$CFLAGS -\(g\|O0\|O2\)"//' -i configure || die
}

src_configure() {
	local ECONF_SOURCE=${S}
	gnome2_src_configure \
		--enable-manpages \
		--disable-strict \
		--disable-coverage \
		--disable-static \
		$(use_enable crypt gcrypt) \
		$(use_enable introspection) \
		$(use_enable vala) \
		LIBGCRYPT_CONFIG="${EPREFIX}/usr/bin/${CHOST}-libgcrypt-config"

	ln -s "${S}"/docs/reference/libsecret/html docs/reference/libsecret/html || die
}

src_test() {
	# tests fail without gobject-introspection
	virtx emake check
}

src_install() {
	gnome2_src_install
}
