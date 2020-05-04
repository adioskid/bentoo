# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# shellcheck disable=SC2034
EAPI=7

inherit multilib-minimal

if [[ "${PV}" == "9999" ]]; then
	EGIT_REPO_URI="https://source.winehq.org/git/vkd3d.git"
	inherit git-r3
else
	KEYWORDS="~amd64"
	SRC_URI="https://dl.winehq.org/vkd3d/source/${P}.tar.xz"
fi

IUSE="demos spirv-tools xcb"
REQUIRED_USE="demos? ( xcb )"
RDEPEND="spirv-tools? ( dev-util/spirv-tools:=[${MULTILIB_USEDEP}] )
		xcb? (
			x11-libs/xcb-util:=[${MULTILIB_USEDEP}]
			x11-libs/xcb-util-keysyms:=[${MULTILIB_USEDEP}]
			x11-libs/xcb-util-wm:=[${MULTILIB_USEDEP}]
		)
		>=media-libs/vulkan-loader-1.1.88[${MULTILIB_USEDEP},X]"

DEPEND="${RDEPEND}
		dev-util/spirv-headers
		>=dev-util/vulkan-headers-1.1.88"

DESCRIPTION="D3D12 to Vulkan translation library"
HOMEPAGE="https://source.winehq.org/git/vkd3d.git/"

LICENSE="LGPL-2.1"
SLOT="0"

multilib_src_configure() {
	local myconf=(
		"$(use_enable demos)"
		"$(use_with spirv-tools)"
		"$(use_with xcb)"
	)

	ECONF_SOURCE=${S} econf "${myconf[@]}"
}

multilib_src_install() {
	default
	if multilib_is_native_abi && use demos; then
		local demo_bin
		pushd "${BUILD_DIR}/demos/.libs/" || die "pushd failed"
		while IFS= read -r -d '' demo_bin; do
			newbin "${demo_bin}" "${PN}-${demo_bin}"
		done < <(find . -maxdepth 1 -executable -type f -printf '%f\0' 2>/dev/null)
		popd || die "popd failed"
	fi
}
