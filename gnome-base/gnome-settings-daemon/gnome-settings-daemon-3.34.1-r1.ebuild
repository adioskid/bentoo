# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"
PYTHON_COMPAT=( python3_7 )

inherit eutils gnome2 python-any-r1 systemd udev virtualx meson

DESCRIPTION="Gnome Settings Daemon"
HOMEPAGE="https://git.gnome.org/browse/gnome-settings-daemon"

LICENSE="GPL-2+"
SLOT="0"
IUSE="+cups debug elogind +networkmanager smartcard systemd test +udev wayland"
KEYWORDS="*"

REQUIRED_USE="
	?? ( elogind systemd )
	smartcard? ( udev )
	wayland? ( udev )
"

COMMON_DEPEND="
	>=dev-libs/glib-2.62.2:2[dbus]
	>=x11-libs/gtk+-3.24.12:3[X,wayland?]
	>=gnome-base/gsettings-desktop-schemas-3.33.0
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
	>=dev-libs/libgweather-3.9.5:2=
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
	wayland? ( dev-libs/wayland )
"

# Themes needed by g-s-d, gnome-shell, gtk+:3 apps to work properly
# <gnome-color-manager-3.1.1 has file collisions with g-s-d-3.1.x
# <gnome-power-manager-3.1.3 has file collisions with g-s-d-3.1.x
# systemd needed for power and session management, bug #464944
RDEPEND="${COMMON_DEPEND}
	gnome-base/dconf
	!<gnome-base/gnome-control-center-2.22
	!<gnome-extra/gnome-color-manager-3.1.1
	!<gnome-extra/gnome-power-manager-3.1.3
	!<gnome-base/gnome-session-3.27.90

	elogind? ( sys-auth/elogind )
	systemd? ( >=sys-apps/systemd-186:0= )
"

# xproto-7.0.15 needed for power plugin
# FIXME: tests require dbus-mock
DEPEND="${COMMON_DEPEND}
	cups? ( sys-apps/sed )
	test? (
		${PYTHON_DEPS}
		$(python_gen_any_dep 'dev-python/pygobject:3[${PYTHON_USEDEP}]')
		gnome-base/gnome-session )
	app-text/docbook-xsl-stylesheets
	dev-libs/libxml2:2
	dev-libs/libxslt
	sys-devel/gettext
	>=dev-util/intltool-0.40
	virtual/pkgconfig
	x11-base/xorg-proto
"

PATCHES=(
#	# Tell gsd to not set DPMS timeouts to '0' (disable) on startup, so DPMS keeps working by default:
	"${FILESDIR}/${PN}-3.34-elementary-dpms-enable.patch"
	# Turn off auto-sleeping when AC power is active, and set battery auto-sleep timeout to 15 minutes:
	"${FILESDIR}/${PN}-3.34-disable-ac-autosleep.patch" 
)

src_prepare() {
	gnome2_src_prepare
}

src_configure() {
	local emesonargs=(
		$(meson_use udev gudev)
		$(meson_use cups)
		$(meson_use networkmanager network_manager)
		$(meson_use smartcard)
		$(meson_use wayland)
		$(meson_use systemd)
	)

	meson_src_configure
	if ! use wayland; then
		# config.h gets a #define HAVE_WAYLAND 0 which is NOT the same as not having it defined.
		# So manually zap is so that wacom sources know it's really not there.
		sed -i -e '/WAYLAND/d' ${S}-build/config.h || die
	fi
}
