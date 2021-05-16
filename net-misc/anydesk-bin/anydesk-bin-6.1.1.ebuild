# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit desktop eutils xdg-utils

DESCRIPTION="Feature rich multi-platform remote desktop application"
HOMEPAGE="https://anydesk.com"
SRC_URI="https://download.anydesk.com/linux/anydesk-6.1.1-amd64.tar.gz"

# OpeSSL/SSLeay, libvpx, zlib, Xiph, xxHash
LICENSE="AnyDesk-TOS BSD BSD-2 openssl ZLIB"
SLOT="0"
KEYWORDS="-* amd64"

DEPEND="dev-util/patchelf"
RDEPEND="
	dev-libs/atk
	dev-libs/glib:2
	virtual/opengl
	media-libs/fontconfig:1.0
	media-libs/freetype:2
	media-libs/glu
	sys-auth/polkit
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:2
	x11-libs/gtkglext
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libxkbfile
	x11-libs/libXmu
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXt
	x11-libs/libXtst
"

QA_PREBUILT="opt/${PN}/*"
S=$WORKDIR/anydesk-${PV}

src_prepare() {
	patchelf --remove-needed libpangox-1.0.so.0 ${S}/anydesk || die patchelf fail
	default
}

src_install() {
	local dst="/opt/anydesk"

	dodir ${dst}
	exeinto ${dst}
	doexe anydesk

	dodir /opt/bin
	dosym ${dst}/anydesk /opt/bin/anydesk
	newinitd "${FILESDIR}"/anydesk.init anydesk
	insinto /usr/share/polkit-1/actions
	doins polkit-1/*.policy
	insinto /usr/share
	doins -r icons
	domenu "${FILESDIR}"/anydesk.desktop
	keepdir /etc/anydesk
	dodoc copyright README
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update

	if [[ -z ${REPLACING_VERSIONS} ]]; then
		elog "To run AnyDesk as background service use:"
		elog
		elog "# rc-service anydesk start"
		elog "# rc-update add anydesk default"
		elog
		elog "Please see README at /usr/share/doc/${PF}/README.bz2 for"
		elog "further information about the linux version of AnyDesk."
		elog
	fi

	elog "For querying information about the host PC AnyDesk calls"
	elog "the following commands. Feel free to install them, but it"
	elog "should run without as well."
	elog
	optfeature "lsb_release" sys-apps/lsb-release
	optfeature "lspci" sys-apps/pciutils
	optfeature "lsusb" sys-apps/usbutils
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}