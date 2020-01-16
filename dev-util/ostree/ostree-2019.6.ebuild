# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Operating system and container binary deployment and upgrades"
HOMEPAGE="https://ostree.readthedocs.io/en/latest/"
SRC_URI="https://github.com/ostreedev/${PN}/releases/download/v${PV}/lib${P}.tar.xz -> ${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="curl doc gjs grub selinux soup systemd zeroconf"

S="${WORKDIR}/lib${P}"
DEPEND="
	dev-libs/glib

	sys-libs/zlib
	app-arch/xz-utils

	app-crypt/gpgme
	sys-fs/fuse:*
	app-arch/libarchive
	dev-libs/openssl:*
	sys-apps/util-linux

	curl? ( net-misc/curl )
	grub? ( sys-boot/grub:* )
	gjs? ( dev-libs/gjs )

	selinux? ( sys-libs/libselinux )
	soup? ( net-libs/libsoup )
	systemd? ( sys-apps/systemd )
	zeroconf? ( net-dns/avahi )
"
RDEPEND="${DEPEND}"
DEPEND="
	${DEPEND}
	sys-devel/flex
	sys-devel/bison
"

src_configure() {
	econf \
		OT_DEP_CRYPTO_CFLAGS=' ' \
		OT_DEP_CURL_CFLAGS=' ' \
		$(use_with curl) \
		$(use_enable doc man) \
		$(use_with soup) \
		--with-crypto=openssl \
		--with-openssl \
		$(use_with selinux ) \
		$(use_with zeroconf avahi)
}
