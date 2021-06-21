EAPI=7

inherit eutils pax-utils xdg-utils

PKG_FILE="${PN}_${PV}_amd64.deb"
DESCRIPTION="Microsoft teams for Linux is your chat-centered workspace in Office 365"
SRC_URI="https://packages.microsoft.com/repos/ms-teams/pool/main/t/teams/${PKG_FILE}"
HOMEPAGE="https://teams.microsoft.com/"
KEYWORDS="*"
SLOT="0"
LICENSE="Microsoft"
IUSE=""

RDEPEND="
	>=media-libs/alsa-lib-1.0.16
	>=app-accessibility/at-spi2-atk-2.5.3
	>=dev-libs/atk-1.12.4
	>=sys-libs/glibc-2.17
	>=x11-libs/cairo-1.6.0
	>=net-print/cups-1.4.0
	>=dev-libs/expat-2.0.1
	>=sys-devel/gcc-3.0.0
	>=x11-libs/gdk-pixbuf-2.22.0
	>=dev-libs/glib-2.35.8
	>=x11-libs/gtk+-3.9.10
	>=dev-libs/nspr-4.9
	>=dev-libs/nss-3.22
	>=x11-libs/pango-1.14.0
	>=app-crypt/libsecret-0.7
	>=sys-apps/util-linux-2.16
	>=x11-libs/libX11-1.4.99
	>=x11-libs/libxcb-1.6
	>=x11-libs/libXcomposite-0.3
	>=x11-libs/libXcursor-1.1.2
	>=x11-libs/libXdamage-1.1
	x11-libs/libXext
	x11-libs/libXfixes
	>=x11-libs/libXi-1.2.99
	x11-libs/libxkbfile
	>=x11-libs/libXrandr-1.2.99
	x11-libs/libXrender
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	>=media-libs/fontconfig-2.11.0
	>=sys-apps/dbus-1.6.18
"

DEPEND="${RDEPEND}"

S="${WORKDIR}"

QA_PREBUILT="*"

src_unpack() {
	unpack ${A}
	rm _gpgorigin control.tar.gz debian-binary
	tar Jxf data.tar.xz && rm data.tar.xz || die
}

src_prepare() {
	sed -i -e "s#Exec=.*teams#Exec=/opt/teams/bin/teams#g" -e "s#Icon=.*teams#Icon=/opt/teams/share/pixmaps/teams.png#g" usr/share/applications/teams.desktop
	sed -i '/OnlyShowIn/d' usr/share/applications/teams.desktop
	default
}

src_install() {
	declare TEAMS_HOME="/opt/${PN}"

	# Install teams in /opt
	into "${TEAMS_HOME}"
	dobin usr/bin/*

	mv "${S}"/usr/share "${ED}"${TEAMS_HOME} || die

	# Create /usr/bin/teams
	dodir /usr/bin/
	cat <<-EOF >"${ED}"/usr/bin/${PN}
	#!/bin/sh
	exec /opt/${PN}/bin/${PN} "\$@"
	EOF
	fperms 0755 /usr/bin/${PN}
	fperms 4755 /opt/teams/share/teams/chrome-sandbox

	dosym '/opt/teams/share/applications/teams.desktop' /usr/share/applications/teams.desktop
}

pkg_postinst() {
	xdg_desktop_database_update
}