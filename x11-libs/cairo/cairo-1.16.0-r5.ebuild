# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils flag-o-matic autotools out-of-source

SRC_URI="https://cairographics.org/releases/${P}.tar.xz"
KEYWORDS="*"

DESCRIPTION="A vector graphics library with cross-device output support"
HOMEPAGE="https://www.cairographics.org/ https://gitlab.freedesktop.org/cairo/cairo"
LICENSE="|| ( LGPL-2.1 MPL-1.1 )"
SLOT="0"
IUSE="X aqua debug gles2-only +glib opengl static-libs +svg utils valgrind xcb"

# Test causes a circular depend on gtk+... since gtk+ needs cairo but test needs gtk+ so we need to block it
RESTRICT="test"

BDEPEND="
	virtual/pkgconfig
	>=sys-devel/libtool-2"
RDEPEND="
	>=dev-libs/lzo-2.06-r1
	>=media-libs/fontconfig-2.10.92
	>=media-libs/freetype-2.5.0.1:2
	>=media-libs/libpng-1.6.10:0=
	sys-libs/binutils-libs:0=
	>=sys-libs/zlib-1.2.8-r1
	>=x11-libs/pixman-0.32.4
	gles2-only? ( >=media-libs/mesa-9.1.6[gles2] )
	glib? ( >=dev-libs/glib-2.34.3:2 )
	opengl? ( >=media-libs/mesa-9.1.6[egl,X(+)] )
	X? (
		>=x11-libs/libXrender-0.9.8
		>=x11-libs/libXext-1.3.2
		>=x11-libs/libX11-1.6.2
	)
	xcb? (
		>=x11-libs/libxcb-1.9.1
	)
"
DEPEND="${RDEPEND}
	X? ( x11-base/xorg-proto )"
#[[ ${PV} == *9999* ]] && DEPEND="${DEPEND}
#	doc? (
#		>=dev-util/gtk-doc-1.6
#		~app-text/docbook-xml-dtd-4.2
#	)"

REQUIRED_USE="
	gles2-only? ( !opengl )
"

PATCHES=(
	"${FILESDIR}"/${PN}-1.12.18-disable-test-suite.patch
	"${FILESDIR}"/${PN}-respect-fontconfig.patch
	"${FILESDIR}"/${P}-pdf-add-missing-flush.patch
	"${FILESDIR}"/${P}-ft-Use-FT_Done_MM_Var-instead-of-free-when-available.patch
	"${FILESDIR}"/${P}-strings.patch
)

src_prepare() {
	default

	if has_version ">=sys-libs/binutils-libs-2.34"; then
		eapply "${FILESDIR}"/${PN}-1.16.0-binutils-2.34.patch
	fi

	# tests and perf tools require X, bug #483574
	if ! use X; then
		sed -e '/^SUBDIRS/ s#boilerplate test perf# #' -i Makefile.am || die
	fi

	# Slightly messed build system YAY
	if [[ ${PV} == *9999* ]]; then
		touch boilerplate/Makefile.am.features
		touch src/Makefile.am.features
		touch ChangeLog
	fi

	eautoreconf
}

src_configure() {
	local myopts

	[[ ${CHOST} == *-interix* ]] && append-flags -D_REENTRANT

	use elibc_FreeBSD && myopts+=" --disable-symbol-lookup"

	# [[ ${PV} == *9999* ]] && myopts+=" $(use_enable doc gtk-doc)"

	ECONF_SOURCE="${S}" \
	econf \
		--disable-dependency-tracking \
		$(use_with X x) \
		$(use_enable X tee) \
		$(use_enable X xlib) \
		$(use_enable X xlib-xrender) \
		$(use_enable X xcb) \
		$(use_enable X xcb-shm) \
		$(use_enable aqua quartz) \
		$(use_enable aqua quartz-image) \
		$(use_enable debug test-surfaces) \
		$(use_enable gles2-only glesv2) \
		$(use_enable glib gobject) \
		$(use_enable opengl gl) \
		$(use_enable static-libs static) \
		$(use_enable svg) \
		$(use_enable utils trace) \
		$(use_enable valgrind) \
		--enable-ft \
		--enable-interpreter \
		--enable-pdf \
		--enable-png \
		--enable-ps \
		--enable-script \
		--disable-drm \
		--disable-directfb \
		--disable-gallium \
		--disable-qt \
		--disable-vg \
		--disable-xlib-xcb \
		${myopts}
}

src_install_all() {
	find "${D}" -name '*.la' -delete || die
	einstalldocs
}
