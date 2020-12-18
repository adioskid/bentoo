# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7,8} )
inherit cmake-utils python-any-r1

DESCRIPTION="Official Vulkan Tools and Utilities for Windows, Linux, Android, and MacOS"
HOMEPAGE="https://github.com/KhronosGroup/Vulkan-Tools"
SRC_URI="https://api.github.com/repos/KhronosGroup/Vulkan-Tools/tarball/sdk-1.2.154.0 -> vulkan-tools-1.2.154.0.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="cube wayland +X"

# Cube demo only supports one window system at a time
REQUIRED_USE="!cube? ( || ( X wayland ) ) cube? ( ^^ ( X wayland ) )"

BDEPEND="${PYTHON_DEPS}
	>=dev-util/cmake-3.10.2
	cube? ( dev-util/glslang:= )
"
RDEPEND="
	>=media-libs/vulkan-loader-${PV}:=[wayland?,X?]
	wayland? ( dev-libs/wayland:= )
	X? (
		x11-libs/libX11:=
		x11-libs/libXrandr:=
	)
"
DEPEND="${RDEPEND}
	>=dev-util/vulkan-headers-${PV}
"

src_unpack() {
	unpack "${A}"
	mv "${WORKDIR}"/KhronosGroup-Vulkan-Tools-* "${S}" || die
}

pkg_setup() {
	python-any-r1_pkg_setup
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=ON
		-DBUILD_VULKANINFO=ON
		-DBUILD_CUBE=$(usex cube)
		-DBUILD_WSI_WAYLAND_SUPPORT=$(usex wayland)
		-DBUILD_WSI_XCB_SUPPORT=$(usex X)
		-DBUILD_WSI_XLIB_SUPPORT=$(usex X)
		-DVULKAN_HEADERS_INSTALL_DIR="${EPREFIX}/usr"
	)

	use cube && mycmakeargs+=(
		-DGLSLANG_INSTALL_DIR="${EPREFIX}/usr"
		-DCUBE_WSI_SELECTION=$(usex X XCB WAYLAND)
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
}