# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit rpm xdg-utils

DESCRIPTION="Serves ProtonMail to IMAP/SMTP clients"
HOMEPAGE="https://protonmail.com/bridge/"
SRC_URI="https://protonmail.com/download/bridge/${P/-bin/}-1.x86_64.rpm"

RESTRICT="bindist mirror"

LICENSE="MIT protonmail-bridge-EULA"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="
	app-crypt/libsecret
	app-crypt/gnupg
	app-admin/pass
	dev-libs/glib:2
	media-sound/pulseaudio[glib]
	sys-apps/dbus
	virtual/opengl
	media-libs/fontconfig
	media-libs/freetype
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libxkbcommon[X]
"
BDEPEND="dev-util/patchelf"

S="${WORKDIR}"

QA_PREBUILT="*"

src_prepare() {
	# Some bogus files got into package.
	rm -rf usr/lib/.build-id

	# Bug #660366. To workaround preserving libs, set RUNPATH and rm unused libs
	cd "${S}/usr/lib/protonmail/bridge" || die
	patchelf --set-rpath '$ORIGIN/lib' proton-bridge || die "patchelf failed"

	default
}

src_install() {
	# Using doins -r would strip executable bits from all binaries
	cp -pPR usr "${D}"/ || die "Failed to copy files"

	dosym "protonmail-bridge" "/usr/bin/${PN}"

	insinto /etc/revdep-rebuild
	newins - "50-${PN}" <<-EOF
		SEARCH_DIRS_MASK="/usr/lib*/protonmail/bridge"
	EOF
}

pkg_postinst() {
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_icon_cache_update
}
