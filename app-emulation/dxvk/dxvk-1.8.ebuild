# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MULTILIB_COMPAT=( abi_x86_{32,64} )
inherit flag-o-matic meson multilib-minimal
if [[ "${PV}" == "9999" ]]; then
	inherit git-r3
fi

DESCRIPTION="Vulkan-based implementation of D3D9, D3D10 and D3D11 for Linux / Wine"
HOMEPAGE="https://github.com/doitsujin/dxvk"
if [[ "${PV}" == "9999" ]]; then
	EGIT_REPO_URI="https://github.com/doitsujin/dxvk.git"
else
	SRC_URI="https://github.com/doitsujin/dxvk/archive/v${PV}.tar.gz -> ${P}.tar.gz"
fi

LICENSE="ZLIB"
SLOT="0"
if [[ "${PV}" == "9999" ]]; then
	KEYWORDS=""
else
	KEYWORDS="~amd64"
fi
IUSE="+d3d9 +d3d10 +d3d11 debug +dxgi video_cards_nvidia test"

DEPEND="
	dev-util/vulkan-headers
	dev-util/glslang
"
RDEPEND="
	media-libs/vulkan-loader[${MULTILIB_USEDEP}]
	|| (
		video_cards_nvidia? ( >=x11-drivers/nvidia-drivers-440.31 )
		>=media-libs/mesa-19.2
	)
	|| (
		>=app-emulation/wine-staging-4.5[${MULTILIB_USEDEP},vulkan]
		>=app-emulation/wine-vanilla-4.5[${MULTILIB_USEDEP},vulkan]
	)
"

PATCHES=(
	"${FILESDIR}/dxvk-1.8_add-compiler-flags.patch"
)

RESTRICT="!test? ( test )"

pkg_pretend () {
	local -a categories
	use abi_x86_64 && categories+=("cross-x86_64-w64-mingw32")
	use abi_x86_32 && categories+=("cross-i686-w64-mingw32")

	for cat in ${categories[@]}; do
		local thread_model="$(LC_ALL=C ${cat/cross-/}-gcc -v 2>&1 \
			  | grep 'Thread model' | cut -d' ' -f3)" || die
		if ! has_version -b ">=${cat}/mingw64-runtime-8.0.0[libraries]" ||
				! has_version -b "${cat}/gcc" ||
				[[ "${thread_model}" != "posix" ]]; then
			eerror "The ${cat} toolchain is not properly installed."
			eerror "Make sure to install ${cat}/mingw64-runtime >= 8.0.0 with USE=\"libraries\""
			eerror "and ${cat}/gcc with EXTRA_ECONF=\"--enable-threads=posix\"."
			eerror "See <https://wiki.gentoo.org/wiki/DXVK> for more information."

			einfo "Alternatively you can install app-emulation/dxvk-bin from the “guru” repo."

			die "${cat} toolchain is not properly installed."
		fi
	done

	einfo "Please report build errors first to the package maintainer via"
	einfo "<https://schlomp.space/tastytea/overlay/issues> or email."
}

src_prepare() {
	default

	# Flag modifications adapted from TheGreatMcPain's overlay.
	if [[ $(is-flag "-march=*") == "true" ]]; then
		append-flags "-mno-avx"
	fi

	sed -i "s|^basedir=.*$|basedir=\"${EPREFIX}\"|" setup_dxvk.sh || die

	# Delete installation instructions for unused ABIs.
	if ! use abi_x86_64; then
		sed -i '/installFile "$win64_sys_path"/d' setup_dxvk.sh || die
	fi
	if ! use abi_x86_32; then
		sed -i '/installFile "$win32_sys_path"/d' setup_dxvk.sh || die
	fi

	patch_build_flags() {
		local bits="${MULTILIB_ABI_FLAG:8:2}"

		# Fix installation directory.
		sed -i "s|\"x${bits}\"|\"usr/$(get_libdir)/dxvk\"|" setup_dxvk.sh || die

		# Add *FLAGS to cross-file.
		sed -i \
			-e "s!@CFLAGS@!$(_meson_env_array "${CFLAGS}")!" \
			-e "s!@CXXFLAGS@!$(_meson_env_array "${CXXFLAGS}")!" \
			-e "s!@LDFLAGS@!$(_meson_env_array "${LDFLAGS}")!" \
			"build-win${bits}.txt" || die
	}
	multilib_foreach_abi patch_build_flags

	# Load configuration file from /etc/dxvk.conf.
	sed -Ei 's|filePath = "^(\s+)dxvk.conf";$|\1filePath = "/etc/dxvk.conf";|' \
		src/util/config/config.cpp || die
}

multilib_src_configure() {
	local bits="${MULTILIB_ABI_FLAG:8:2}"

	local emesonargs=(
		--libdir="$(get_libdir)/dxvk"
		--bindir="$(get_libdir)/dxvk"
		--cross-file="${S}/build-win${bits}.txt"
		--buildtype="release"
		$(usex debug "" "--strip")
		$(meson_use d3d9 "enable_d3d9")
		$(meson_use d3d10 "enable_d3d10")
		$(meson_use d3d11 "enable_d3d11")
		$(meson_use dxgi "enable_dxgi")
		$(meson_use test "enable_tests")
	)
	meson_src_configure
}

multilib_src_compile() {
	EMESON_SOURCE="${S}"
	meson_src_compile
}

multilib_src_install() {
	meson_src_install
}

multilib_src_install_all() {
	# The .a files are needed during the install phase.
	find "${D}" -name '*.a' -delete -print

	dobin setup_dxvk.sh

	insinto etc
	doins "dxvk.conf"

	default
}

pkg_postinst() {
	elog "dxvk is installed, but not activated. You have to create DLL overrides"
	elog "in order to make use of it. To do so, set WINEPREFIX and execute"
	elog "setup_dxvk.sh install --symlink."

	elog "D9VK is part of DXVK since 1.5. If you use symlinks, don't forget to link the new libraries."
}
