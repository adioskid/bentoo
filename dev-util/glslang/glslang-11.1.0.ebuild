# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CMAKE_ECLASS="cmake"
PYTHON_COMPAT=( python3_{7,8,9} )
inherit cmake-multilib python-any-r1

DESCRIPTION="Khronos reference front-end for GLSL and ESSL, and sample SPIR-V generator"
HOMEPAGE="https://www.khronos.org/opengles/sdk/tools/Reference-Compiler/ https://github.com/KhronosGroup/glslang"
SRC_URI="https://api.github.com/repos/KhronosGroup/glslang/tarball/11.1.0 -> glslang-11.1.0.tar.gz"

LICENSE="BSD"
SLOT="0"

RDEPEND="!<media-libs/shaderc-2020.1"
BDEPEND="${PYTHON_DEPS}"

# Bug 698850
RESTRICT="test"

src_unpack() {
	unpack "${A}"
	mv "${WORKDIR}"/KhronosGroup-glslang-* "${S}" || die
}
