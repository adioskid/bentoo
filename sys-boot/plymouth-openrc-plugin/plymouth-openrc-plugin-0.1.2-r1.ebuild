# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit eutils multilib

DESCRIPTION="Plymouth plugin for OpenRC"
HOMEPAGE="https://github.com/aidecoe/plymouth-openrc-plugin"
#SRC_URI="https://dev.gentoo.org/~aidecoe/distfiles/${CATEGORY}/${PN}/${P}.tar.bz2"
#SRC_URI="https://github.com/aidecoe/plymouth-openrc-plugin/archive/v0.1.2.tar.gz -> ${PN}-0.1.2.tar.gz"
SRC_URI="https://github.com/aidecoe/plymouth-openrc-plugin/archive/master.zip -> ${PN}-0.1.2.zip"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="+silent"
DEPEND=">=sys-apps/openrc-0.8.2-r1"
RDEPEND="${DEPEND}
	>=sys-boot/plymouth-0.8.3-r5
	"

S="${WORKDIR}/plymouth-openrc-plugin-master"

src_prepare() {
	if use silent; then
		epatch "${FILESDIR}/no-text.patch"
	fi
}

src_install() {
	insinto /$(get_libdir)/rc/plugins
	doins plymouth.so
}

pkg_postinst() {
	ewarn "You need to disable 'interactive' feature in /etc/rc.conf to make"
	ewarn "Plymouth work properly with OpenRC init system."

	if [[ ! -d /run ]]; then
		eerror "/run doesn't exist!  You need to create this directory."
		echo
		einfo "If you'd like to know more about purpose of /run, please read:"
		einfo "  https://lwn.net/Articles/436012/"
	fi

	if has_version sys-apps/systemd; then
		eerror "sys-apps/systemd is installed, please uninstall this package if you"
		eerror "are booting with systemd"
	fi
}
