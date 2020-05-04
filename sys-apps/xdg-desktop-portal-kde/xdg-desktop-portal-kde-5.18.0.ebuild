# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools kde5

DESCRIPTION="A backend implementation for xdg-desktop-portal that is using Qt/KDE"
HOMEPAGE="https://community.kde.org/Guidelines_and_HOWTOs/Flatpak"
LICENSE="LGPL-2.1"

SRC_URI="https://github.com/KDE/xdg-desktop-portal-kde/archive/v${PV}.tar.gz"

KEYWORDS="~amd64 ~x86"
IUSE=""

COMMON_DEPEND="
	$(add_frameworks_dep kcoreaddons)
	$(add_frameworks_dep knotifications)
	$(add_frameworks_dep ki18n)
	$(add_qt_dep qtwidgets)
	$(add_qt_dep qtdbus)
	$(add_qt_dep qtprintsupport)
"
DEPEND="${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}"
