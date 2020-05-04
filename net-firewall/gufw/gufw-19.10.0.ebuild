# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_COMPAT=( python2_7 python3_{6,7} )
DISTUTILS_IN_SOURCE_BUILD=1

inherit distutils-r1 versionator

MY_PN="gui-ufw"
MY_PV="$(get_version_component_range 1-2)"

DESCRIPTION="GUI frontend for managing ufw."
HOMEPAGE="https://gufw.org/"
SRC_URI="https://launchpad.net/${MY_PN}/trunk/${MY_PV}/+download/${MY_PN}-${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-python/python-distutils-extra"
RDEPEND="net-firewall/ufw
	x11-libs/gtk+[introspection]
	net-libs/webkit-gtk[introspection]
	dev-python/netifaces
	sys-auth/polkit
	x11-themes/gnome-icon-theme-symbolic
"

S=${WORKDIR}/${MY_PN}-${PV}

