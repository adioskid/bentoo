# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PV2=$(ver_cut 1-2)
MY_PV3=$(ver_cut 1-3)
MY_PV4=$(ver_cut 4)
SRC_URI="https://downloadarchive.documentfoundation.org/libreoffice/old/7.1.1.2/rpm/x86_64/LibreOffice_7.1.1.2_Linux_x86-64_rpm.tar.gz"

inherit prefix rpm toolchain-funcs xdg-utils

DESCRIPTION="A full office productivity suite. Binary package"
HOMEPAGE="https://www.libreoffice.org"

IUSE="gnome gstreamer +gtk java kde zeroconf"
LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="-* ~amd64"

BIN_COMMON_DEPEND="
	=app-text/libexttextcat-3.4*
	=app-text/libmwaw-0.3*
	>=dev-libs/icu-64.2
	>=media-gfx/graphite2-1.3.10
	media-libs/harfbuzz:0/0.9.18[icu]
	media-libs/libpng:0/16
	>=sys-devel/gcc-8.3.0
	>=sys-libs/glibc-2.29
	virtual/jpeg-compat:62
"

# PLEASE place any restrictions that are specific to the binary builds
# into the BIN_COMMON_DEPEND block above.
# All dependencies below this point should remain identical to those in
# the source ebuilds.

COMMON_DEPEND="
	${BIN_COMMON_DEPEND}
	app-arch/unzip
	app-arch/zip
	app-crypt/gpgme[cxx]
	app-text/hunspell:=
	>=app-text/libabw-0.1.0
	>=app-text/libebook-0.1
	app-text/libepubgen
	>=app-text/libetonyek-0.1
	app-text/libexttextcat
	app-text/liblangtag
	>=app-text/libmspub-0.1.0
	>=app-text/libmwaw-0.3.1
	app-text/libnumbertext
	>=app-text/libodfgen-0.1.0
	app-text/libqxp
	app-text/libstaroffice
	app-text/libwpd:0.10[tools]
	app-text/libwpg:0.3
	>=app-text/libwps-0.4
	app-text/mythes
	>=dev-cpp/clucene-2.3.3.4-r2
	=dev-cpp/libcmis-0.5*
	dev-db/unixODBC
	dev-lang/perl
	dev-libs/boost:=[nls]
	dev-libs/expat
	dev-libs/hyphen
	dev-libs/icu:=
	dev-libs/libassuan
	dev-libs/libgpg-error
	>=dev-libs/liborcus-0.14.0
	dev-libs/librevenge
	dev-libs/libxml2
	dev-libs/libxslt
	dev-libs/nspr
	dev-libs/nss
	>=dev-libs/redland-1.0.16
	>=dev-libs/xmlsec-1.2.24[nss]
	media-gfx/fontforge
	media-gfx/graphite2
	media-libs/fontconfig
	media-libs/freetype:2
	>=media-libs/harfbuzz-0.9.42:=[graphite,icu]
	media-libs/lcms:2
	>=media-libs/libcdr-0.1.0
	>=media-libs/libepoxy-1.3.1[X]
	>=media-libs/libfreehand-0.1.0
	media-libs/libpagemaker
	>=media-libs/libpng-1.4:0=
	>=media-libs/libvisio-0.1.0
	media-libs/libzmf
	net-libs/neon
	net-misc/curl
	sci-mathematics/lpsolve
	sys-libs/zlib
	virtual/glu
	virtual/jpeg:0
	virtual/opengl
	x11-libs/cairo[X]
	x11-libs/libXinerama
	x11-libs/libXrandr
	x11-libs/libXrender
	net-print/cups
	sys-apps/dbus
	gnome? ( gnome-extra/evolution-data-server )
	gstreamer? ( media-libs/gstreamer:1.0 )
	media-libs/gst-plugins-base:1.0
	gtk? (
		dev-libs/glib:2
		dev-libs/gobject-introspection
		gnome-base/dconf
		media-libs/mesa[egl]
		x11-libs/gtk+:3
		x11-libs/pango
	)
	kde? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtwidgets:5
		dev-qt/qtx11extras:5
		kde-frameworks/kconfig:5
		kde-frameworks/kcoreaddons:5
		kde-frameworks/ki18n:5
		kde-frameworks/kio:5
		kde-frameworks/kwindowsystem:5
	)
	dev-db/mariadb-connector-c
	zeroconf? ( net-dns/avahi )
"

RDEPEND="${COMMON_DEPEND}
	!app-office/libreoffice
	!app-office/openoffice
	media-fonts/liberation-fonts
	|| ( x11-misc/xdg-utils kde-plasma/kde-cli-tools )
	java? ( >=virtual/jre-1.6 )
	kde? ( kde-frameworks/breeze-icons:* )
	app-crypt/mit-krb5
"

PDEPEND="
	=app-office/libreoffice-l10n-${PV}*
"

DEPEND="${COMMON_DEPEND}"

REQUIRED_USE="gnome? ( gtk )"

RESTRICT="test strip"

S="${WORKDIR}"

#PYTHON_UPDATER_IGNORE="1"

QA_PREBUILT="/usr/*"

src_prepare() {
	cp "${FILESDIR}"/50-${PN} "${T}"
	eprefixify "${T}"/50-${PN}
	default

	local rpmdir
	use amd64 && rpmdir="LibreOffice_${PV}_Linux_x86-64_rpm/RPMS/"
	[[ -d ${rpmdir} ]] || die "Missing directory: ${rpmdir}"

	# Unpack RPMs but consider USE flags
	for rpms in ./${rpmdir}/*.rpm; do
		if [[ ${rpms} == "./${rpmdir}/libobasis${MY_PV2}-kde-integration-${PV}-${MY_PV4}.x86_64.rpm" ]]; then
			use kde && rpm_unpack ${rpms}
		elif [[ ${rpms} == "./${rpmdir}/libobasis${MY_PV2}-gnome-integration-${PV}-${MY_PV4}.x86_64.rpm" ]]; then
			use gtk && rpm_unpack ${rpms}
		else
			rpm_unpack ${rpms}
		fi
	done

	# Remove files that require zeroconf if USE flag not set
	use zeroconf || rm -f ./opt/libreoffice${MY_PV2}/program/libsdlo.so
	use zeroconf || rm -f ./opt/libreoffice${MY_PV2}/program/libsdfiltlo.so
	use zeroconf || rm -f ./opt/libreoffice${MY_PV2}/program/libsduilo.so
	# Remove files that require java if USE flag not set
	use java || rm -f ./opt/libreoffice${MY_PV2}/program/libofficebean.so
	# Remove files that require gstreamer if USE flag not set
	use gstreamer || rm -f ./opt/libreoffice${MY_PV2}/program/libavmediagst.so
}

src_configure() { :; }

src_compile() { :; }

src_install() {
	local progdir=/usr/$(get_libdir)/libreoffice
	dodir ${progdir}
	mv "${S}"/opt/libreoffice"${MY_PV2}"/* "${ED}"/"${progdir}"/

	rm ./usr/bin/libreoffice"${MY_PV2}"
	dosym "${progdir}"/program/soffice /usr/bin/libreoffice"${MY_PV2}"
	dosym "${progdir}"/program/soffice /usr/bin/libreoffice
	dosym "${progdir}"/program/soffice /usr/bin/loffice
	dosym "${progdir}"/program/soffice /usr/bin/soffice

	for prog in base impress calc math writer draw; do
		dosym "${progdir}"/program/s"${prog}" /usr/bin/lo"${prog}"
	done

	rm ./usr/share/applications/*
	mkdir -p "${ED}"/usr/share/applications

	for prog in base impress startcenter calc math writer draw xsltfilter; do
		cp "${ED}"/"${progdir}"/share/xdg/"${prog}".desktop "${ED}"/usr/share/applications/libreoffice"${MY_PV2}"-"${prog}".desktop
	done

	doins -r usr

	# prevent revdep-rebuild from attempting to rebuild all the time
	insinto /etc/revdep-rebuild && doins "${T}/50-${PN}"
}

pkg_postinst() {
	xdg_icon_cache_update
	xdg_desktop_database_update
	xdg_mimeinfo_database_update

	use java || \
		ewarn 'If you plan to use lbase application you should enable java or you will get various crashes.'
}

pkg_postrm() {
	xdg_icon_cache_update
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}