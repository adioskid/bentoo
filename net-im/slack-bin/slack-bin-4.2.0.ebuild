# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN="${PN/-bin/}"
MULTILIB_COMPAT=( abi_x86_64 )

inherit desktop multilib-build pax-utils unpacker xdg-utils

DESCRIPTION="Team collaboration tool"
HOMEPAGE="https://www.slack.com/"
SRC_URI="https://downloads.slack-edge.com/linux_releases/${MY_PN}-desktop-${PV}-amd64.deb"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="ayatana gnome-keyring"
RESTRICT="bindist mirror"

RDEPEND="app-accessibility/at-spi2-atk:2
	dev-libs/atk:0
	dev-libs/expat:0
	dev-libs/glib:2
	dev-libs/nspr:0
	dev-libs/nss:0
	media-libs/alsa-lib:0
	media-libs/mesa:0
	net-print/cups:0
	sys-apps/dbus:0
	sys-apps/util-linux:0
	x11-libs/cairo:0
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libX11:0
	x11-libs/libxcb:0/1.12
	x11-libs/libXcomposite:0
	x11-libs/libXcursor:0
	x11-libs/libXdamage:0
	x11-libs/libXext:0
	x11-libs/libXfixes:0
	x11-libs/libXi:0
	x11-libs/libxkbfile:0
	x11-libs/libXrandr:0
	x11-libs/libXrender:0
	x11-libs/libXScrnSaver:0
	x11-libs/libXtst:0
	x11-libs/pango:0
	ayatana? ( dev-libs/libappindicator:3 )
	gnome-keyring? ( app-crypt/libsecret:0 )"

QA_PREBUILT="/opt/slack/chrome-sandbox
	opt/slack/slack
	opt/slack/resources/app.asar.unpacked/node_modules/*
	opt/slack/libffmpeg.so
	opt/slack/libEGL.so
	opt/slack/libGLESv2.so
	opt/slack/swiftshader/libEGL.so
	opt/slack/swiftshader/libGLESv2.so"

S="${WORKDIR}"

src_prepare() {
	default

	# remove hardcoded path (wrt 694058)
	sed -i '/Icon/s|/usr/share/pixmaps/slack.png|slack|' \
		usr/share/applications/slack.desktop \
		|| die "sed failed in Icon for slack.desktop"

	if use ayatana ; then
		sed -i '/Exec/s|=|=env XDG_CURRENT_DESKTOP=Unity |' \
			usr/share/applications/slack.desktop \
			|| die "sed failed for slack.desktop"
	fi
}

src_install() {
	doicon usr/share/pixmaps/slack.png
	doicon -s 512 usr/share/pixmaps/slack.png
	domenu usr/share/applications/slack.desktop

	insinto /opt/slack
	doins -r usr/lib/slack/.
	fperms +x /opt/slack/slack
	dosym ../../opt/slack/slack usr/bin/slack

	pax-mark -m "${ED%/}"/opt/slack/slack
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update
	xdg_mimeinfo_database_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
	xdg_mimeinfo_database_update
}
