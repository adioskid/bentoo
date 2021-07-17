# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop eutils unpacker pax-utils xdg

MY_PN="${PN/-bin}"
MY_INSTALL_DIR="/opt/balenaEtcher"
MY_EXEC="balena-${MY_PN}-electron"
DESCRIPTION="Flash OS images to SD cards & USB drives, safely and easily."
HOMEPAGE="https://etcher.io/"
SRC_URI="https://github.com/balena-io/etcher/releases/download/v1.5.121/balena-etcher-electron_1.5.121_amd64.deb -> etcher-bin-1.5.121.deb"
RESTRICT="mirror strip"
LICENSE="GPL2"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="
	media-libs/libpng
    >=x11-libs/gtk+-3.0
    x11-libs/cairo
    x11-libs/libXtst
	sys-apps/lsb-release
"

RDEPEND="
	${DEPEND}
	x11-libs/libnotify
    x11-libs/libXScrnSaver
    dev-libs/nss
"

src_unpack() {
	# etcher does not use a containing folder(deb archive)
	# manual intervention required
    install -d "${WORKDIR}/${P}"
    S="${WORKDIR}/${P}"
	cd "${S}" || die "cd into target directory ${S} failed"
	unpack_deb "${A}"
}

src_install() {
	doins -r *
    dosym "${MY_INSTALL_DIR}/${MY_EXEC}" "/usr/bin/${MY_PN}" || die
    make_wrapper "${MY_PN}" "${MY_INSTALL_DIR}/${MY_EXEC}" || die
	# only contains changelog"
	rm -rf "${D}/usr/share/doc" || die
	# use own desktop file
	rm -fR "${D}/usr/share/applications" || die
	domenu "${FILESDIR}/${MY_PN}.desktop" || die

	# correct permissions of install components
	fperms 4755 "${MY_INSTALL_DIR}/chrome-sandbox" || die
	fperms a+x "${MY_INSTALL_DIR}/${MY_EXEC}" || die
	fperms a+x "${MY_INSTALL_DIR}/${MY_EXEC}.bin" || die
	pax-mark m "${MY_INSTALL_DIR}/${MY_EXEC}" || die
}

pkg_postinst() {
	xdg_pkg_postinst
}

pkg_postrm() {
	xdg_pkg_postrm
}