# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN=${PN/-bin/}
MY_BIN="D${MY_PN/d/}"

inherit desktop linux-info pax-utils unpacker xdg

DESCRIPTION="All-in-one voice and text chat for gamers"
HOMEPAGE="https://discordapp.com"
SRC_URI="https://dl-canary.discordapp.net/apps/linux/${PV}/discord-canary-${PV}.deb"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror bindist"

RDEPEND="
	app-accessibility/at-spi2-atk:2
	app-accessibility/at-spi2-core:2
	dev-libs/atk
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/fontconfig:1.0
	media-libs/freetype:2
	net-print/cups
	sys-apps/dbus
	sys-apps/util-linux
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

S="${WORKDIR}"

QA_PREBUILT="
	opt/discord/${MY_BIN}
	opt/discord/chrome-sandbox
	opt/discord/libffmpeg.so
	opt/discord/libvk_swiftshader.so
	opt/discord/libvulkan.so
	opt/discord/libEGL.so
	opt/discord/libGLESv2.so
	opt/discord/libVkICD_mock_icd.so
	opt/discord/swiftshader/libEGL.so
	opt/discord/swiftshader/libGLESv2.so
	opt/discord/swiftshader/libvk_swiftshader.so
"

CONFIG_CHECK="~USER_NS"

src_prepare() {
	default

	mv -v "${S}/usr/share/discord-canary" "${S}/usr/share/discord"
	mv -v "${S}/usr/share/discord/DiscordCanary" "${S}/usr/share/discord/Discord"
	mv -v "${S}/usr/share/discord/discord-canary.desktop" "${S}/usr/share/discord/discord.desktop"

	sed -i \
		-e "s:/usr/share/discord-canary/Discord.*:/opt/discord/Discord:g" \
		-e "s:discord-canary:discord:g" \
		usr/share/discord/discord.desktop || die
	install -d "${S}/opt"
	mv -v "${S}/usr/share/discord" "${S}/opt/discord" || die
	rm -v "${S}/usr/bin/discord-canary"
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
