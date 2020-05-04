# Distributed under the terms of the GNU General Public License v2

EAPI=6
GNOME2_LA_PUNT="yes"

inherit flag-o-matic gnome3 meson virtualx

DESCRIPTION="Gimp ToolKit +"
HOMEPAGE="https://www.gtk.org/"

LICENSE="LGPL-2+"
SLOT="3"
IUSE="aqua broadway cloudprint colord cups +doc examples +introspection test vim-syntax wayland +X xinerama"
REQUIRED_USE="
	|| ( aqua wayland X )
	xinerama? ( X )
	colord? ( cups )
"

KEYWORDS="*"

# Upstream wants us to do their job:
# https://bugzilla.gnome.org/show_bug.cgi?id=768662#c1
RESTRICT="test"

# FIXME: introspection data is built against system installation of gtk+:3,
# bug #????
COMMON_DEPEND="
	>=dev-libs/atk-2.15[introspection?]
	>=dev-libs/glib-2.62.2:2
	media-libs/fontconfig
	>=media-libs/libepoxy-1.4[X(+)?]
	>=x11-libs/cairo-1.16.0[aqua?,glib,svg,X?]
	>=x11-libs/gdk-pixbuf-2.39.2:2[introspection?]
	>=x11-libs/pango-1.44.7[introspection?]
	x11-misc/shared-mime-info

	cloudprint? (
		>=net-libs/rest-0.7
		>=dev-libs/json-glib-1.0 )
	colord? ( >=x11-misc/colord-0.1.9:0= )
	cups? ( >=net-print/cups-1.2 )
	introspection? ( >=dev-libs/gobject-introspection-1.62.0:= )
	wayland? (
		>=dev-libs/wayland-1.14.91
		>=dev-libs/wayland-protocols-1.16
		media-libs/mesa[wayland]
		>=x11-libs/libxkbcommon-0.2
	)
	X? (
		>=app-accessibility/at-spi2-atk-2.5.3
		x11-libs/libX11
		>=x11-libs/libXi-1.3
		x11-libs/libXext
		>=x11-libs/libXrandr-1.5
		x11-libs/libXcursor
		x11-libs/libXfixes
		x11-libs/libXcomposite
		x11-libs/libXdamage
		xinerama? ( x11-libs/libXinerama )
	)
"
DEPEND="${COMMON_DEPEND}
	app-text/docbook-xsl-stylesheets
	app-text/docbook-xml-dtd:4.1.2
	dev-libs/libxslt
	dev-libs/gobject-introspection-common
	>=dev-util/gdbus-codegen-2.48
	>=dev-util/gtk-doc-am-1.20
	doc? ( >=dev-util/gtk-doc-1.20 )
	>=sys-devel/gettext-0.19.7
	virtual/pkgconfig
	X? ( x11-base/xorg-proto )
	test? (
		media-fonts/font-misc-misc
		media-fonts/font-cursor-misc )
"
# gtk+-3.2.2 breaks Alt key handling in <=x11-libs/vte-0.30.1:2.90
# gtk+-3.3.18 breaks scrolling in <=x11-libs/vte-0.31.0:2.90
RDEPEND="${COMMON_DEPEND}
	>=dev-util/gtk-update-icon-cache-3
	!<gnome-base/gail-1000
	!<x11-libs/vte-0.31.0:2.90
"
# librsvg for svg icons (PDEPEND to avoid circular dep), bug #547710
PDEPEND="
	gnome-base/librsvg
	>=x11-themes/adwaita-icon-theme-3.14
	vim-syntax? ( app-vim/gtk-syntax )
"

MULTILIB_CHOST_TOOLS=(
	/usr/bin/gtk-query-immodules-3.0$(get_exeext)
)

strip_builddir() {
	local rule=$1
	shift
	local directory=$1
	shift
	sed -e "s/^\(${rule} =.*\)${directory}\(.*\)$/\1\2/" -i $@ \
		|| die "Could not strip director ${directory} from build."
}

src_prepare() {
	# -O3 and company cause random crashes in applications. Bug #133469
	replace-flags -O3 -O2
	strip-flags

	# gtk-update-icon-cache is installed by dev-util/gtk-update-icon-cache
	eapply "${FILESDIR}"/${PN}-3.24.12-update-icon-cache.patch

	# call eapply_user (implicitly) before eautoreconf
	gnome3_src_prepare
}

src_configure() {
	local print_backends="file,lpr"
	if use cups; then
		print_backends="$print_backends,cups"
	fi
	if use cloudprint; then
		print_backends="$print_backends,cloudprint"
	fi
	local emesonargs=(
		-Dc_args="$CFLAGS"
		-Dprint_backends=$print_backends
		-Dquartz_backend=$(usex aqua true false)
		-Dbroadway_backend=$(usex broadway true false)
		-Dcolord=$(usex colord yes no)
		-Dwayland_backend=$(usex wayland true false)
		-Dx11_backend=$(usex X true false)
		-Dxinerama=$(usex xinerama yes no)
		-Dgtk_doc=$(usex doc true false)
		-Dcloudproviders=false
		-Dwin32_backend=false
		-Dtests=$(usex test true false)
		-Ddemos=$(usex examples true false)
		-Dexamples=$(usex examples true false)
		-Dinstalled_tests=false
		-Dintrospection=$(usex introspection true false)
		-Dman=true
		-Dbuiltin_immodules=auto
	)

	meson_src_configure
}

src_test() {
	"${EROOT}${GLIB_COMPILE_SCHEMAS}" --allow-any-name "${S}/gtk" || die
	GSETTINGS_SCHEMA_DIR="${S}/gtk" virtx emake check
}

src_install() {
	meson_src_install

	insinto /etc/gtk-3.0
	doins "${FILESDIR}"/settings.ini
	# Skip README.{in,commits,win32} and useless ChangeLog that would get installed by default
	DOCS=( AUTHORS NEWS README )
	einstalldocs
}

pkg_preinst() {
	gnome3_pkg_preinst

    # Make immodules.cache belongs to gtk+ alone
    local cache="usr/$(get_libdir)/gtk-3.0/3.0.0/immodules.cache"

    if [[ -e ${EROOT}${cache} ]]; then
        cp "${EROOT}"${cache} "${ED}"/${cache} || die
    else
        touch "${ED}"/${cache} || die
    fi
}

pkg_postinst() {
	gnome3_pkg_postinst
	gnome3_query_immodules_gtk3 || die "Update immodules cache failed"

	if ! has_version "app-text/evince"; then
		elog "Please install app-text/evince for print preview functionality."
		elog "Alternatively, check \"gtk-print-preview-command\" documentation and"
		elog "add it to your settings.ini file."
	fi
}

pkg_postrm() {
	gnome3_pkg_postrm
	if [[ -z ${REPLACED_BY_VERSION} ]]; then
		rm -f "${EROOT}"usr/$(get_libdir)/gtk-3.0/3.0.0/immodules.cache
	fi
}
