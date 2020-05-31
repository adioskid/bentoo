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
BDEPEND=""

src_prepare() {
	default
}

src_install() {
	insinto /usr/include/EGL
	doins ${S}/interface/eglexternalplatform.h eglexternalplatformversion.h
}