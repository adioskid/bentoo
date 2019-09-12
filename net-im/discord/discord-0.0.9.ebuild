# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils gnome2-utils unpacker

DESCRIPTION="All-in-one voice and text chat for gamers"
HOMEPAGE="https://discordapp.com"
SRC_URI="https://dl.discordapp.net/apps/linux/${PV}/${P}.deb"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="amd64"
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
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:2
	x11-libs/libX11
	x11-libs/libXScrnSaver
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

S=${WORKDIR}

RESTRICT="mirror bindist"

QA_PREBUILT="
	opt/discord/share/discord/Discord
	opt/discord/share/discord/libnode.so
	opt/discord/share/discord/libffmpeg.so
"

src_unpack() {
	unpack_deb ${A}
}

src_prepare() {
	default

	sed -i \
		-e "s:/usr/share/discord/Discord:discord:g" \
		usr/share/${PN}/${PN}.desktop || die
}

src_install() {
	insinto /opt/${PN}
	doins -r usr/.

	fperms +x /opt/${PN}/bin/${PN}
	dosym /opt/${PN}/bin/${PN} /usr/bin/${PN}
	dosym /opt/${PN}/share/applications/${PN}.desktop \
		/usr/share/applications/${PN}.desktop
	dosym /opt/${PN}/share/pixmaps/${PN}.png \
		/usr/share/pixmaps/${PN}.png
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
} 
