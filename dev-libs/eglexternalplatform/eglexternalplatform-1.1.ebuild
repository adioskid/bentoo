# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils

HOMEPAGE="https://github.com/NVIDIA/eglexternalplatform"
DESCRIPTION="The EGL External Platform interface"
SRC_URI="https://github.com/NVIDIA/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

src_prepare() {
	default
}

src_install() {
	insinto /usr/include/EGL
	doins ${S}/interface/*
	mv "${ED}/${PN}.pc" "${ED}/usr/$(get_libdir)/pkgconfig/${PN}.pc"
}