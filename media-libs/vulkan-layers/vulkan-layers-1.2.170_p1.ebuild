# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN=Vulkan-ValidationLayers
CMAKE_ECLASS="cmake"
PYTHON_COMPAT=( python3_{7..9} )
inherit cmake-multilib python-any-r1

COMMIT="4fdcd0eebfed3505732720fc6fd98293e847d697"
SRC_URI="https://github.com/KhronosGroup/Vulkan-ValidationLayers/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"

DESCRIPTION="Vulkan Validation Layers"
HOMEPAGE="https://github.com/KhronosGroup/Vulkan-ValidationLayers"

LICENSE="Apache-2.0"
SLOT="0"
IUSE="wayland X"

S="${WORKDIR}/Vulkan-ValidationLayers-${COMMIT}"

BDEPEND=">=dev-util/cmake-3.10.2"
DEPEND="${PYTHON_DEPS}
	>=dev-util/glslang-10.11.0.0_pre20201216:=[${MULTILIB_USEDEP}]
	>=dev-util/spirv-tools-2020.6:=[${MULTILIB_USEDEP}]
	>=dev-util/vulkan-headers-${PV}
	wayland? ( dev-libs/wayland:=[${MULTILIB_USEDEP}] )
	X? (
		x11-libs/libX11:=[${MULTILIB_USEDEP}]
		x11-libs/libXrandr:=[${MULTILIB_USEDEP}]
	)
"

multilib_src_configure() {
	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=ON
		-DBUILD_LAYER_SUPPORT_FILES=ON
		-DBUILD_WSI_WAYLAND_SUPPORT=$(usex wayland)
		-DBUILD_WSI_XCB_SUPPORT=$(usex X)
		-DBUILD_WSI_XLIB_SUPPORT=$(usex X)
		-DBUILD_TESTS=OFF
		-DVULKAN_HEADERS_INSTALL_DIR="${EPREFIX}/usr/include/vulkan"
		-DGLSLANG_INSTALL_DIR="${EPREFIX}/usr"
		-DCMAKE_INSTALL_INCLUDEDIR="${EPREFIX}/usr/include/vulkan"
		-DSPIRV_HEADERS_INSTALL_DIR="${EPREFIX}/usr/include/spirv"
		#-DSPIRV_TOOLS_INSTALL_DIR="{EPREFIX}/usr/include/spirv"
	)
	cmake_src_configure
}