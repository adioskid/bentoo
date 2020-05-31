# Distributed under the terms of the GNU General Public License v2

EAPI="6"
inherit gnome3 virtualx meson

DESCRIPTION="GNOME 3 compositing window manager based on Clutter"
HOMEPAGE="https://git.gnome.org/browse/mutter/"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="elogind +gles2 input_devices_wacom +introspection nvidia -profiler -test udev wayland"
REQUIRED_USE="
	wayland? ( elogind )
	test? ( wayland )
"

# libXi-1.7.4 or newer needed per:
# https://bugzilla.gnome.org/show_bug.cgi?id=738944
COMMON_DEPEND="
	>=dev-libs/atk-2.5.3
	>=x11-libs/gdk-pixbuf-2.39.2:2
	>=dev-libs/json-glib-0.12.0
	>=x11-libs/pango-1.44.7[introspection?]
	>=x11-libs/cairo-1.16.0[X]
	>=x11-libs/gtk+-3.24.12:3[X,introspection?]
	>=dev-libs/glib-2.62.2:2[dbus]
	>=media-libs/libcanberra-0.26[gtk3]
	>=x11-libs/startup-notification-0.7
	>=x11-libs/libXcomposite-0.2
	>=gnome-base/gsettings-desktop-schemas-3.32[introspection?]
	gnome-base/gnome-desktop:3=
	gnome-base/gnome-settings-daemon:0=
	>sys-power/upower-0.99:=

	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	>=x11-libs/libXcomposite-0.4
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	>=x11-libs/libXfixes-3
	>=x11-libs/libXi-1.7.4
	x11-libs/libXinerama
	>=x11-libs/libXrandr-1.5
	x11-libs/libXrender
	x11-libs/libxcb
	x11-libs/libxkbfile
	>=x11-libs/libxkbcommon-0.4.3[X]
	x11-misc/xkeyboard-config

	gnome-extra/zenity
	media-libs/mesa[egl]

	gles2? ( media-libs/mesa[gles2] )
	input_devices_wacom? ( >=dev-libs/libwacom-0.13 )
	introspection? ( >=dev-libs/gobject-introspection-1.62.0:= )
	udev? ( >=virtual/libgudev-232:= )
	wayland? (
		>=dev-libs/libinput-1.4
		>=dev-libs/wayland-1.6.90
		>=dev-libs/wayland-protocols-1.16
		>=media-libs/mesa-10.3[egl,gbm,wayland]
		|| ( sys-auth/elogind sys-apps/systemd )
		>=virtual/libudev-232:=
		x11-base/xorg-server[wayland]
		x11-libs/libdrm:=
		nvidia? ( dev-libs/wayland )
	)
	media-video/pipewire
	profiler? ( >=dev-util/sysprof-3.34.0 )
"

DEPEND="${COMMON_DEPEND}
	>=sys-devel/gettext-0.19.6
	virtual/pkgconfig
	x11-base/xorg-proto
	test? ( app-text/docbook-xml-dtd:4.5 )
	wayland? ( >=sys-kernel/linux-headers-4.4 )
"
RDEPEND="${COMMON_DEPEND}
	!x11-misc/expocity
"

PATCHES=(	"${FILESDIR}/${PN}-3.34.2-add-get-color-info.patch"
			"${FILESDIR}/${PN}-3.34.2-support-eudev.patch"
			"${FILESDIR}/gdk-wayland-fix.patch" )

src_configure() {
	sed -i "/'-Werror=redundant-decls',/d" "${S}"/meson.build || die "sed failed"

	local emesonargs=(
		-Dopengl=true
		-Degl=true
		-Dglx=true
		-Dsm=true
		-Dremote_desktop=true
		$(meson_use gles2)
		$(meson_use introspection)
		$(meson_use wayland)
		$(meson_use wayland egl_device)
		$(meson_use nvidia wayland_eglstream)
		$(meson_use gles2 native_backend)
		$(meson_use udev)
		$(meson_use profiler)
		$(meson_use input_devices_wacom libwacom)
		$(meson_use test tests)
	)

	meson_src_configure
}
