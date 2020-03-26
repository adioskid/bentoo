# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils

DESCRIPTION="Plymouth plugin for OpenRC"
HOMEPAGE="https://github.com/aidecoe/plymouth-openrc-plugin"

MY_PV=${PV/_p*}

COMMIT="4f22b915bf7a9cccd2734bb5abbeb1ffe77d39dd"
SRC_URI="https://github.com/aidecoe/${PN}/archive/${COMMIT}.tar.gz -> ${PN}-${MY_PV}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE=""

DEPEND="sys-apps/openrc:="
RDEPEND="${DEPEND}
	sys-boot/plymouth"

S="${WORKDIR}/${PN}-${COMMIT}"

PATCHES=(
	"${FILESDIR}/no-text.patch"
)

src_install() {
	insinto /$(get_libdir)/rc/plugins
	doins plymouth.so
}

pkg_postinst() {
	ewarn "You need to disable 'rc_interactive' feature in /etc/rc.conf to make"
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
