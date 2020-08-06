# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_INSTALL_DIR="/opt/discord"
inherit desktop eutils unpacker pax-utils xdg

DESCRIPTION="All-in-one voice and text chat for gamers"
HOMEPAGE="https://discordapp.com"
SRC_URI="https://dl.discordapp.net/apps/linux/${PV}/discord-${PV}.deb"
RESTRICT="mirror bindist"
LICENSE="all-rights-reserved"
SLOT="0"
S="${WORKDIR}"

KEYWORDS="~amd64"
IUSE=""

RDEPEND="
	dev-libs/atk
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	gnome-base/gconf:2
	media-libs/alsa-lib
	media-libs/fontconfig:1.0
	media-libs/freetype:2
	net-print/cups
	sys-apps/dbus
	sys-libs/libcxx
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXScrnSaver
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXtst
	x11-libs/pango
"

QA_PREBUILT="
	opt/discord/Discord
	opt/discord/libEGL.so
	opt/discord/libGLESv2.so
	opt/discord/swiftshader/libEGL.so
	opt/discord/swiftshader/libGLESv2.so
	opt/discord/libVkICD_mock_icd.so
	opt/discord/libffmpeg.so
"

src_prepare() {
	default

	sed -i \
		-e "s:/usr/share/discord/Discord:/opt/discord/Discord:g" \
		usr/share/discord/discord.desktop || die
	install -d "${S}/opt"
	mv -v "${S}/usr/share/discord" "${S}/opt/discord" || die
	rm -v "${S}/usr/bin/discord"
}


src_install() {
	doicon opt/discord/discord.png
	domenu opt/discord/discord.desktop

	insinto /opt/discord
	doins -r opt/discord/.

	fperms +x /opt/discord/Discord
	fperms 4755 /opt/discord/chrome-sandbox || die
	dosym ../../opt/discord/Discord usr/bin/discord
	pax-mark -m "${ED%/}"/opt/discord/discord
}

pkg_postinst() {
	xdg_mimeinfo_database_update
	xdg_icon_cache_update
	xdg_desktop_database_update
}

pkg_postrm() {
	xdg_mimeinfo_database_update
	xdg_icon_cache_update
	xdg_desktop_database_update
}