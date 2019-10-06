# Copyright 2011-2019 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit readme.gentoo-r1 systemd
RESTRICT="mirror" # until available on gentoo mirrors

DESCRIPTION="Scripts to support compressed swap devices or ramdisks with zram"
HOMEPAGE="https://github.com/vaeth/zram-init/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~ppc ~ppc64 ~x86"
IUSE="split-usr"

RDEPEND=">=app-shells/push-2.0-r2
	!<sys-apps/openrc-0.13"

DISABLE_AUTOFORMATTING="true"
DOC_CONTENTS="To use zram, activate it in your kernel and add it to default runlevel:
	rc-config add zram default
If you use systemd enable zram_swap, tmp, and/or var_tmp with systemctl.
You might need to modify /etc/modprobe.d/zram.conf"

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env sh$"#!'"/bin/sh"'"' \
		-- sbin/* || die
	default
}

src_install() {
	doinitd openrc/init.d/*
	doconfd openrc/conf.d/*
	systemd_dounit systemd/system/*
	insinto /etc/modprobe.d
	doins modprobe.d/*
	insinto /usr/share/zsh/site-functions
	doins zsh/*
	dodoc AUTHORS ChangeLog README.md
	readme.gentoo_create_doc
	into $(get_usr)/
	dosbin sbin/*
}

pkg_postinst() {
	readme.gentoo_print_elog
}

get_usr() {
	use split-usr || echo /usr
}
