# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop pax-utils

DESCRIPTION="Open Source Software Binaries of VSCode"
HOMEPAGE="https://github.com/VSCodium/vscodium"
SRC_URI="https://github.com/VSCodium/vscodium/releases/download/${PV}/VSCodium-linux-x64-${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror strip bindist"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="libsecret"

DEPEND="
	>=media-libs/libpng-1.2.46:0
	>=x11-libs/gtk+-3.0:3
	x11-libs/cairo
	x11-libs/libXtst
"

RDEPEND="
	${DEPEND}
	>=net-print/cups-2.0.0
	x11-libs/libnotify
	x11-libs/libXScrnSaver
	dev-libs/nss
	libsecret? ( app-crypt/libsecret[crypt] )
"

QA_PRESTRIPPED="
	opt/${PN}/code
"

S="${WORKDIR}"

src_install() {
	pax-mark m code
	insinto "/opt/${PN}"
	doins -r *
	dosym "/opt/${PN}/bin/codium" "/usr/bin/${PN}"
	dosym "/opt/${PN}/bin/codium" "/usr/bin/codium"
	make_desktop_entry "${PN}" "VSCodium" "${PN}" "Development;IDE"
	newicon "resources/app/resources/linux/code.png" ${PN}.png
	fperms +x "/opt/${PN}/codium"
	fperms +x "/opt/${PN}/bin/codium"
	fperms +x "/opt/${PN}/resources/app/node_modules.asar.unpacked/vscode-ripgrep/bin/rg"
	insinto "/usr/share/licenses/${PN}"
}

pkg_postinst() {
	elog "You may install some additional utils, so check them in:"
	elog "https://code.visualstudio.com/Docs/setup#_additional-tools"
	elog ""
	elog "Upstream renamed the binary from vscodium to codium."
	elog "remember to update your aliases and shortcuts"
}
