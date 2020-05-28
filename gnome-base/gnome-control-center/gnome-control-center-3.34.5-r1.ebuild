# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit bash-completion-r1 gnome.org meson

DESCRIPTION="GNOME's main interface to configure various aspects of the desktop"
HOMEPAGE="https://git.gnome.org/browse/gnome-control-center/"

LICENSE="GPL-2+"
SLOT="2"
KEYWORDS="*"

IUSE="elogind +ibus libinput systemd v4l wayland"
REQUIRED_USE="
	?? ( elogind systemd )
	wayland? ( || ( elogind systemd ) )
"

# False positives caused by nested configure scripts
QA_CONFIGURE_OPTIONS=".*"

COMMON_DEPEND="
	>=dev-libs/glib-2.62.2:2[dbus]
	dev-libs/libhandy
	>=x11-libs/gdk-pixbuf-2.39.2:2
	>=x11-libs/gtk+-3.24.12:3[X,wayland?]
	>=gnome-base/gsettings-desktop-schemas-3.28.0
	>=gnome-base/gnome-desktop-3.34.1:3=
	>=gnome-base/gnome-settings-daemon-3.25.2
	>=x11-misc/colord-0.1.34:0=

	>=dev-libs/libpwquality-1.2.2
	dev-libs/libxml2:2
	gnome-base/libgtop:2=
	media-libs/fontconfig
	>=sys-apps/accountsservice-0.6.39

	>=media-libs/gsound-1.0.2
	>=media-libs/libcanberra-0.13[gtk3]
	>=media-sound/pulseaudio-2[glib]
	>=sys-auth/polkit-0.97
	>=sys-power/upower-0.99:=

	virtual/libgudev
	x11-apps/xmodmap
	x11-libs/cairo
	x11-libs/libX11
	>=x11-libs/libXi-1.2
	>=media-libs/clutter-1.11.3[gtk]
	media-libs/clutter-gtk[gtk]

	>=net-wireless/gnome-bluetooth-3.31.1:=
	net-libs/libsoup:2.4
	>=x11-misc/colord-0.1.34:0=
	>=x11-libs/colord-gtk-0.1.24

	>=net-fs/samba-4.0.0[client]

	>=media-libs/grilo-0.3.0:0.3=
	>=net-libs/gnome-online-accounts-3.27.92:=
	ibus? ( >=app-i18n/ibus-1.5.2 )
	app-crypt/mit-krb5
	>=gnome-extra/nm-applet-1.2.0
	>=net-misc/networkmanager-1.2.0:=[modemmanager]
	>=net-misc/modemmanager-0.7.990
	v4l? ( >=media-video/cheese-3.5.91 )
	>=dev-libs/libwacom-0.7
	>=x11-libs/libXi-1.2
	sys-apps/bolt
"
# <gnome-color-manager-3.1.2 has file collisions with g-c-c-3.1.x
# libgnomekbd needed only for gkbd-keyboard-display tool
#
# mouse panel needs a concrete set of X11 drivers at runtime, bug #580474
# Also we need newer driver versions to allow wacom and libinput drivers to
# not collide
RDEPEND="${COMMON_DEPEND}
	x11-themes/adwaita-icon-theme
	>=gnome-extra/gnome-color-manager-3.28.0
	gnome-base/gnome-settings-daemon
	ibus? ( >=gnome-base/libgnomekbd-3 )
	wayland? ( libinput? ( dev-libs/libinput ) )
	!wayland? (
		libinput? ( >=x11-drivers/xf86-input-libinput-0.19.0 )
		>=x11-drivers/xf86-input-wacom-0.33.0 )

	!<gnome-base/gdm-2.91.94
	!<gnome-extra/gnome-color-manager-3.1.2
	!gnome-extra/gnome-media[pulseaudio]
	!<gnome-extra/gnome-media-2.32.0-r300
	!<net-wireless/gnome-bluetooth-3.3.2

	net-print/cups-pk-helper

	elogind? ( sys-auth/elogind )
	systemd? ( >=sys-apps/systemd-186:0= )
	!systemd? ( app-admin/openrc-settingsd )
"
# PDEPEND to avoid circular dependency
PDEPEND=">=gnome-base/gnome-session-2.91.6-r1"

DEPEND="${COMMON_DEPEND}
	x11-base/xorg-proto

	dev-libs/libxml2:2
	dev-libs/libxslt
	>=dev-util/intltool-0.40.1
	>=sys-devel/gettext-0.17
	virtual/pkgconfig

	gnome-base/gnome-common
"

src_configure() {
	local emesonargs=(
		-Doption=disable-update-mimedb
		-Doption=disable-static
		$(meson_use ibus)
		$(meson_use v4l cheese)
		$(meson_use wayland)
	)

	meson_src_configure
}

src_install() {
	addwrite /usr/share/icons
	meson_src_install completiondir="$(get_bashcompdir)"
}
