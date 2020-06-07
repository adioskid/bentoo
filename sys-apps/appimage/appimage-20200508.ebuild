# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils autotools

DESCRIPTION="Linux apps that run anywhere"
HOMEPAGE="https://appimage.org/"

COMMIT="df8b13c19e569a6db0b9d186c81dd1ae4afbf58a"
SRC_URI="https://github.com/${PN}/${PN}kit/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/AppImageKit-${COMMIT}"

LICENSE="GPL-3"
SLOT="0"

DEPEND="
	sys-libs/glibc
	app-arch/libarchive
	dev-libs/glib
	sys-libs/zlib
	sys-fs/fuse

	"
RDEPEND="
	${DEPEND}
	sys-apps/dbus
	media-libs/fontconfig
	net-libs/glib-networking
	media-libs/gstreamer
	media-libs/gst-plugins-base
	media-libs/gst-plugins-good
	media-libs/gst-plugins-ugly
	media-sound/pulseaudio
	x11-libs/libdrm
	media-libs/mesa
	x11-libs/gtk+
	"
BDEPEND=""

src_unpack() {
	unpack ${A}
}

src_prepare() {
	default
}

src_install() {
	cd "${S}" || die
	DESTDIR="${D}" chmod +x ./build.sh || die "Error"
}