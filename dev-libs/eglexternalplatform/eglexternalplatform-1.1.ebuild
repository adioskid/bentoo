# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils


HOMEPAGE="https://github.com/NVIDIA/eglexternalplatform"
DESCRIPTION="The EGL External Platform interface"
SRC_URI="https://github.com/NVIDIA/eglexternalplatform/archive/1.1.tar.gz"

LICENSE="MIT"
SLOT="0"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

src_prepare() {
	default
	eautoreconf
}

src_install() {
	default
	insinto /usr/include/EGL
	install_pkgconfig eglexternalplatform.pc

	asdfas.sh

	doins eglexternalplatform.pc
	#newins "${DISTDIR}"/include/eglexternalplatform.h eglexternalplatformversion.h
}