# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils multilib

DESCRIPTION="NVIDIA Linux X11 Settings Utility"
HOMEPAGE="http://www.nvidia.com/"
SRC_URI="https://download.nvidia.com/XFree86/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86 ~x86-fbsd"
IUSE="dbus +gtk3 vdpau +system-jansson"

RDEPEND="x11-drivers/nvidia-drivers
        system-jansson? ( >=dev-libs/jansson-2.2 )
        x11-libs/gdk-pixbuf[X]
        x11-libs/libX11
        x11-libs/libXext
        x11-libs/libXrandr
        x11-libs/libXv
        x11-libs/libXxf86vm
        gtk3? ( x11-libs/gtk+:3 )
        !gtk3? ( x11-libs/gtk+:2 )
        dbus? ( sys-apps/dbus )
        vdpau? ( x11-libs/libvdpau )"
DEPEND="${RDEPEND}"

PATCHES=(
    ${FILESDIR}/nvidia-settings-gtk-independence.patch
    ${FILESDIR}/nvidia-settings-linker.patch
)

src_prepare() {

    default

	# Fix up a couple of typos which prevent the gtk2 version from building.
	sed -e '/^# Build $(IMAGE_HEADERS)/,/^$(GTK2_OBJS): $(IMAGE_HEADERS)/ { s/GTK3/GTK2/; s/$(GTK2_OBJS)/  &/; };' \
		-i src/Makefile
}

src_compile() {

	emake -C src \
		AR="$(tc-getAR)" CC="$(tc-getCC)" LD="$(tc-getCC)" NVLD="$(tc-getLD)" RANLIB="$(tc-getRANLIB)" \
		DO_STRIP= NV_VERBOSE=1 \
		PREFIX="${EPREFIX}/usr" LIBDIR="$(get_libdir)" \
		build-xnvctrl

	emake -C src \
		AR="$(tc-getAR)" CC="$(tc-getCC)" LD="$(tc-getCC)" NVLD="$(tc-getLD)" RANLIB="$(tc-getRANLIB)" \
		DO_STRIP= NV_VERBOSE=1 NVML_ENABLED=1 \
		NV_USE_BUNDLED_LIBJANSSON=$(use !system-jansson | echo $?) GTK3_AVAILABLE=$(usex gtk3 1 0) \
		PREFIX="${EPREFIX}/usr" LIBDIR="$(get_libdir)"

	emake -C doc NV_VERBOSE=1 NVML_ENABLED=1 PREFIX="${EPREFIX}/usr"

}

src_install() {

	emake -C src \
		DO_STRIP= NV_VERBOSE=1 NVML_ENABLED=1 \
		NV_USE_BUNDLED_LIBJANSSON=$(use !system-jansson | echo $?) GTK3_AVAILABLE=$(usex gtk3 1 0) \
		PREFIX="${EPREFIX}/usr" LIBDIR="${ED}/usr/$(get_libdir)" \
		DESTDIR="${D}" install

	emake -C doc \
		NV_VERBOSE=1 NVML_ENABLED=1 PREFIX="${EPREFIX}/usr" \
		DESTDIR="${D}" install

	# Install static lib
	dolib.a src/libXNVCtrl/libXNVCtrl.a

	# Install headers
	insinto /usr/include/NVCtrl
	doins src/libXNVCtrl/*.h

	# Install docs
	dodoc doc/nvidia-settings.png doc/FRAMELOCK.txt doc/NV-CONTROL-API.txt

	# Install desktop file
	dodir "/usr/share/applications"
	sed -e 's|__UTILS_PATH__|'"${EPREFIX}/usr/bin"'|' \
		-e 's|__PIXMAP_PATH__|'"${EPREFIX}/usr/share/doc/${PF}/"'|' \
		-e 's|__NVIDIA_SETTINGS_DESKTOP_CATEGORIES__|Settings;HardwareSettings;|' \
		"${S}/doc/nvidia-settings.desktop" > "${ED}/usr/share/applications/nvidia-settings.desktop"

}

