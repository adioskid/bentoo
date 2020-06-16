# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Plymouth plugin for OpenRC"
HOMEPAGE="https://github.com/Kangie/plymouth-openrc-plugin"
SRC_URI="https://github.com/Kangie/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"
IUSE="+silent"

DEPEND="sys-apps/openrc"
RDEPEND="${DEPEND}
	sys-boot/plymouth
	sys-apps/openrc
	!sys-apps/systemd"

PATCHES=(
	"${FILESDIR}/no-text.patch"
)

src_install() {
	insinto /$(get_libdir)/rc/plugins
	doins plymouth.so
}

pkg_postinst() {
	if [[ -z ${REPLACING_VERSIONS} ]]; then
		ewarn "You need to disable 'rc_interactive' feature in /etc/rc.conf to make"
		ewarn "Plymouth work properly with OpenRC init system."
	fi

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
