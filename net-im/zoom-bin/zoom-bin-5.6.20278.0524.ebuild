# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit unpacker xdg

MY_PN="${PN/-bin/}"

DESCRIPTION="Video conferencing and web conferencing service"
HOMEPAGE="https://zoom.us"
SRC_URI="https://cdn.zoom.us/prod/5.6.20278.0524/zoom_x86_64.pkg.tar.xz -> zoom-5.6.20278.0524_x86_64.pkg.tar.xz"

LICENSE="ZOOM"
SLOT="0"
KEYWORDS="amd64"

RESTRICT="mirror strip preserve-libs"

IUSE="pulseaudio"

QA_PREBUILT="opt/zoom/*"

RDEPEND="${DEPEND}
	pulseaudio? ( media-sound/pulseaudio )
	app-i18n/ibus
	dev-libs/glib:2
	dev-libs/libxslt
	dev-libs/nss
	media-libs/fontconfig
	media-libs/mesa
	sys-apps/dbus
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXtst
	x11-libs/libxcb
	x11-libs/libxshmfence
	x11-libs/xcb-util-image
	x11-libs/xcb-util-keysyms
"
DEPEND="${RDEPEND}
	app-admin/chrpath
"

S=${WORKDIR}

src_prepare() {
	rm -f ${WORKDIR}/.PKGINFO ${WORKDIR}/.INSTALL ${WORKDIR}/.MTREE
	rmdir usr/share/doc/zoom usr/share/doc
	sed -i -e 's:Icon=Zoom.png:Icon=Zoom:' "${WORKDIR}/usr/share/applications/Zoom.desktop"
	sed -i -e 's:Application;::' "${WORKDIR}/usr/share/applications/Zoom.desktop"
	chrpath -r '' opt/zoom/platforminputcontexts/libfcitxplatforminputcontextplugin.so
	scanelf -Xr opt/zoom/platforminputcontexts/libfcitxplatforminputcontextplugin.so
	eapply_user
}

src_install() {
	cp -Rp "${S}/"* "${D}"
}

pkg_preinst() {
	xdg_pkg_preinst
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	xdg_icon_cache_update
}