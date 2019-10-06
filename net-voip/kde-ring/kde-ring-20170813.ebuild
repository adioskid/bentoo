# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
CMAKE_IN_SOURCE_BUILD="true"

if [[ ${PV} == *99999999* ]]; then
	inherit kde5

	EGIT_REPO_URI="git://anongit.kde.org/ring-kde"
	EGIT_COMMIT="23001bde2271a1a38364d1febd7ab49d2b0289c5"
	SRC_URI=""

	KEYWORDS=""
else
	inherit kde5 git-r3

	EGIT_REPO_URI="git://anongit.kde.org/ring-kde"
	EGIT_COMMIT="23001bde2271a1a38364d1febd7ab49d2b0289c5"
	SRC_URI=""

	KEYWORDS="~amd64"
fi

DESCRIPTION="KDE Ring client"
HOMEPAGE="https://projects.savoirfairelinux.com/projects/ring-kde-client/wiki"

LICENSE="GPL-3"

SLOT="0"

IUSE="akonadi doc +video system-libringclient"
	# using the system-libringclient currently doesn't work

RDEPEND="
	$(add_frameworks_dep kcompletion)
	$(add_frameworks_dep kconfig)
	$(add_frameworks_dep kcrash)
	$(add_frameworks_dep kdbusaddons)
	$(add_frameworks_dep kdeclarative)
	$(add_frameworks_dep kglobalaccel)
	$(add_frameworks_dep kguiaddons)
	$(add_frameworks_dep ki18n)
	$(add_frameworks_dep kiconthemes)
	$(add_frameworks_dep kinit)
	$(add_frameworks_dep kio)
	$(add_frameworks_dep knotifications)
	$(add_frameworks_dep knotifyconfig)
	$(add_frameworks_dep kwidgetsaddons)
	$(add_frameworks_dep kwindowsystem)
	$(add_frameworks_dep kxmlgui)
	$(add_qt_dep qtgui)
	$(add_qt_dep qtprintsupport)
	$(add_qt_dep qtquickcontrols2)
	$(add_qt_dep qtsvg)
	$(add_qt_dep qtwidgets)
	akonadi? ( $(add_kdeapps_dep akonadi) $(add_kdeapps_dep akonadi-contacts) $(add_kdeapps_dep kcontacts) )
	system-libringclient? ( net-libs/libringclient[video?] )
	!system-libringclient? ( !net-libs/libringclient )
"

DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

kde5_src_configure()  {
		local mycmakeargs=(
		-DENABLE_VIDEO="$(usex video true false)"
		-DCMAKE_INSTALL_PREFIX=/usr
		-DCMAKE_BUILD_TYPE=Release
	)
	cmake-utils_src_configure
}

kde5_src_install() {
	use doc && doxygen Doxyfile
	use doc && HTML_DOCS=( "${S}/html/" )
	use !doc && rm {AUTHORS,NEWS,README.md}
	cmake-utils_src_install
}
