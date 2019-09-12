# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN="${PN/-bin}"
SRC_URI_BASE="https://github.com/electron/electron/releases/download"
DESCRIPTION="Cross platform application development framework based on web technologies"
HOMEPAGE="https://electron.atom.io"
SRC_URI="
	amd64? ( ${SRC_URI_BASE}/v${PV}/${MY_PN}-v${PV}-linux-x64.zip -> ${P}-x64.zip )
	arm? ( ${SRC_URI_BASE}/v${PV}/${MY_PN}-v${PV}-linux-armv7l.zip -> ${P}-armv7l.zip )
	arm64? ( ${SRC_URI_BASE}/v${PV}/${MY_PN}-v${PV}-linux-arm64.zip -> ${P}-arm64.zip )
	x86? ( ${SRC_URI_BASE}/v${PV}/${MY_PN}-v${PV}-linux-ia32.zip -> ${P}-ia32.zip )
"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="3.0"
KEYWORDS="-* ~amd64 ~arm ~arm64 ~x86"

RDEPEND="
	dev-libs/atk
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nss
	media-gfx/graphite2
	media-libs/alsa-lib
	media-libs/fontconfig:1.0
	media-libs/libepoxy
	media-libs/libpng
	net-print/cups
	sys-apps/dbus
	virtual/opengl
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libxcb
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-libs/pango
"
DEPEND="app-arch/unzip"

S="${WORKDIR}"

OPTPATH="opt/${MY_PN}-${SLOT}"
QA_PRESTRIPPED="${OPTPATH}/.*"

src_install() {
	dodir "/${OPTPATH}"
	# Note: intentionally not using "doins" so that we preserve +x bits
	cp -r ./* "${ED}/${OPTPATH}" || die

	dosym "../../${OPTPATH}/electron" "/usr/bin/electron-${SLOT}"
}
