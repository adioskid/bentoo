# Distributed under the terms of the GNU General Public License v2

EAPI=7
GNOME3_LA_PUNT="yes"
PYTHON_COMPAT=( python3_{6,7,8} )

inherit eutils gnome3 python-any-r1 udev virtualx meson

DESCRIPTION="Gnome Settings Daemon"
HOMEPAGE="https://git.gnome.org/browse/gnome-settings-daemon"

LICENSE="GPL-2+"
SLOT="0"
IUSE="+cups debug elogind +networkmanager smartcard +udev wayland"
KEYWORDS="*"

REQUIRED_USE="
	elogind
	smartcard? ( udev )
	wayland? ( udev )
"

BASE_PV="${PV%.*}"

COMMON_DEPEND="
	>=dev-libs/libgweather-3.36:=
	>=dev-libs/glib-2.62.2:2[dbus]
	>=x11-libs/gtk+-3.24.12:3[X,wayland?]
	>=gnome-base/gsettings-desktop-schemas-${BASE_PV}
	>=gnome-base/librsvg-2.36.2:2
	media-fonts/cantarell
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/libcanberra[gtk3]
	>=media-sound/pulseaudio-2
	>=sys-power/upower-0.99:=
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	>=x11-libs/libnotify-0.7.3:=
	x11-libs/libX11
	x11-libs/libxkbfile
	x11-libs/libXi
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXtst
	x11-misc/xkeyboard-config
	>=app-misc/geoclue-2.3.1:2.0
	>=sci-geosciences/geocode-glib-3.10
	>=sys-auth/polkit-0.113-r5
	>=media-libs/lcms-2.2:2
	>=x11-misc/colord-1.0.2:=
	cups? ( >=net-print/cups-1.4[dbus] )
	>=dev-libs/libwacom-0.7
	>=x11-libs/pango-1.44.7
	x11-drivers/xf86-input-wacom
	virtual/libgudev:=
	networkmanager? ( >=net-misc/networkmanager-1.0 )
	smartcard? ( >=dev-libs/nss-3.11.2 )
	udev? ( virtual/libgudev:= )
	wayland? ( dev-libs/wayland )"

RDEPEND="${COMMON_DEPEND}
	gnome-base/dconf
	>=gnome-base/gnome-control-center-${PV}
	>=gnome-extra/gnome-color-manager-${BASE_PV}
	>=gnome-extra/gnome-power-manager-3.32
	>=gnome-base/gnome-session-${BASE_PV}
	sys-auth/elogind
"

DEPEND="${COMMON_DEPEND}
	!wayland? ( x11-base/xorg-proto )
	app-text/docbook-xsl-stylesheets
	dev-libs/libxml2:2
	dev-libs/libxslt
	sys-devel/gettext
	>=dev-util/intltool-0.40
	virtual/pkgconfig
"

# Tell gsd to not set DPMS timeouts to '0' (disable) on startup, so DPMS keeps working by default:
# Turn off auto-sleeping when AC power is active, and set battery auto-sleep timeout to 15 minutes:

PATCHES=(
	"${FILESDIR}/${PN}-3.34-elementary-dpms-enable.patch"
	"${FILESDIR}/${PN}-3.34-disable-ac-autosleep.patch"
)

src_prepare() {
	gnome3_src_prepare
}

src_configure() {
	local emesonargs=(
		$(meson_use udev gudev)
		$(meson_use cups)
		$(meson_use networkmanager network_manager)
		$(meson_use smartcard)
		$(meson_use wayland)
		-Dsystemd=false
	)

	meson_src_configure
	if ! use wayland; then
		# config.h gets a #define HAVE_WAYLAND 0 which is NOT the same as not having it defined.
		# So manually zap is so that wacom sources know it's really not there.
		sed -i -e '/WAYLAND/d' ${S}-build/config.h || die
	fi
}
