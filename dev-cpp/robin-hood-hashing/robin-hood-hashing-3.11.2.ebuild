# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="C++ fast and memory efficient hashtable based on robin hood hashing"
HOMEPAGE="https://github.com/martinus/robin-hood-hashing"
SRC_URI="https://api.github.com/repos/martinus/robin-hood-hashing/tarball/3.11.2 -> robin-hood-hashing-3.11.2.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"

BDEPEND="
	virtual/pkgconfig
"

src_unpack() {
	default
	rm -rf "${S}"
	mv "${WORKDIR}"/martinus-robin-hood-hashing-* "${S}" || die
}

src_configure() {
	local mycmakeargs=(
		-DRH_STANDALONE_PROJECT=OFF
	)
	
	cmake_src_configure
}