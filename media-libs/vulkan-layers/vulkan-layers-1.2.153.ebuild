# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN=Vulkan-ValidationLayers
CMAKE_ECLASS="cmake"
PYTHON_COMPAT=( python3_{6,7,8} )
inherit cmake python-any-r1

if [[ ${PV} == *9999* ]]; then
	EGIT_REPO_URI="https://github.com/KhronosGroup/${MY_PN}.git"
	EGIT_SUBMODULES=()
	inherit git-r3
else
	SRC_URI="https://github.com/KhronosGroup/${MY_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="amd64 ~arm ~arm64 ~ppc ~ppc64 x86"
	S="${WORKDIR}"/${MY_PN}-${PV}
fi

DESCRIPTION="Vulkan Validation Layers"
HOMEPAGE="https://github.com/KhronosGroup/Vulkan-ValidationLayers"

LICENSE="Apache-2.0"
SLOT="0"
IUSE="wayland X"

BDEPEND=">=dev-util/cmake-3.10.2"
DEPEND="${PYTHON_DEPS}
	media-libs/mesa
	>=dev-util/glslang-8.13.3743
	>=dev-util/spirv-tools-2020.3
	>=dev-util/vulkan-headers-${PV}
	wayland? ( dev-libs/wayland )
	X? (
		x11-libs/libX11
		x11-libs/libXrandr
		x11-libs/libxcb
		x11-libs/libxkbcommon
	)
"

src_configure() {
	local mycmakeargs=(
		#-DCMAKE_SKIP_RPATH=ON
		-DBUILD_LAYER_SUPPORT_FILES=ON
		-DBUILD_WSI_WAYLAND_SUPPORT=$(usex wayland)
		-DBUILD_WSI_XCB_SUPPORT=$(usex X)
		-DBUILD_WSI_XLIB_SUPPORT=$(usex X)
		-DBUILD_TESTS=OFF
		-DGLSLANG_INSTALL_DIR="${EPREFIX}/usr"
		-DCMAKE_INSTALL_INCLUDEDIR="${EPREFIX}/usr/include/vulkan/"
		-DVULKAN_HEADERS_INSTALL_DIR="${EPREFIX}/usr"
		-DSPIRV_HEADERS_INSTALL_DIR="${EPREFIX}/usr"
		-DSPIRV_TOOLS_INSTALL_DIR="${EPREFIX}/usr"
	)
	cmake_src_configure
}
