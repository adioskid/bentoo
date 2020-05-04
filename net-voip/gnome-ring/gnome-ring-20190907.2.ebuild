# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

if [[ ${PV} == *99999999* ]]; then
	inherit eutils git-r3 cmake-utils gnome2-utils

	EGIT_REPO_URI="https://gerrit-ring.savoirfairelinux.com/ring-client-gnome"
	SRC_URI=""

	KEYWORDS=""
else
	inherit eutils cmake-utils gnome2-utils

	COMMIT_HASH="e3a1ec5"
	MY_SRC_P="ring_${PV}.${COMMIT_HASH}"
	SRC_URI="https://dl.ring.cx/ring-release/tarballs/${MY_SRC_P}.tar.gz"

	KEYWORDS="~amd64"

	S=${WORKDIR}/ring-project/client-gnome
fi

DESCRIPTION="Gnome Ring client"
HOMEPAGE="https://tuleap.ring.cx/projects/ring"

LICENSE="GPL-3"

SLOT="0"

IUSE="-appindicator +libnotify networkmanager +qrcode static-libs"

DEPEND=">=app-text/libebook-0.1.2
	appindicator? ( dev-libs/libappindicator:3 )
	gnome-extra/evolution-data-server
	~net-libs/libringclient-${PVR}
	networkmanager? ( net-misc/networkmanager )
	media-libs/clutter-gtk
	media-libs/libcanberra
	qrcode? ( media-gfx/qrencode )
	>=dev-qt/qtcore-5
	>=dev-qt/qtgui-5
	>=dev-qt/qtwidgets-5
	net-libs/webkit-gtk:4
	sys-devel/gettext
	x11-themes/adwaita-icon-theme
	libnotify? ( x11-libs/libnotify )
"

RDEPEND="${DEPEND}"

src_configure() {
#	BUILD_DIR=${WORKDIR}/build
	mkdir build
	cd build
#	local mycmakeargs=(
#		-DENABLE_STATIC="$(usex static-libs true false)"
#		-DGSETTINGS_COMPILE=OFF
#		-DCMAKE_INSTALL_PREFIX=/usr
#		-DCMAKE_BUILD_TYPE=Release
#	)
#	cmake-utils_src_configure
	cmake .. -DENABLE_STATIC="$(usex static-libs true false)" -DCMAKE_INSTALL_PREFIX=/usr -DGSETTINGS_COMPILE=OFF -DCMAKE_BUILD_TYPE=Release || die "Configure failed"

        # fix sandbox violation
        sed -i 's/EXECUTE_PROCESS/#NOOP/' cmake_install.cmake
}

src_compile() {
	cd build
	default
}

src_install() {
	cd build
	default
}

pkg_preinst() {
	gnome2_schemas_savelist
}

pkg_postinst() {
	gnome2_schemas_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_schemas_update
	gnome2_icon_cache_update
}
