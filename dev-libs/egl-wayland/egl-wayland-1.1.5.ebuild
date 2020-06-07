# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson


HOMEPAGE="https://github.com/NVIDIA/egl-wayland"
DESCRIPTION="The EGLStream-based Wayland external platform"
SRC_URI="https://github.com/NVIDIA/${PN}/archive/${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="
	dev-libs/wayland
	media-libs/libglvnd
	"

RDEPEND="${DEPEND}"
BDEPEND="
	dev-util/ninja
	dev-util/meson
	"

src_prepare() {
	default
}

src_configure() {
	default
	meson_src_configure
}

src_compile() {
	meson_src_compile
}

src_install() {
	meson_src_install
}