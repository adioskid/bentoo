# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils


HOMEPAGE="https://github.com/NVIDIA/eglexternalplatform"
DESCRIPTION="The EGL External Platform interface"
SRC_URI="https://github.com/NVIDIA/eglexternalplatform/archive/1.1.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

src_prepare() {
	default
	eautoreconf
}

src_install() {
	insinto /usr/include/EGL
	newins "${DISTDIR}"/include/eglexternalplatform.h eglexternalplatformversion.h
}