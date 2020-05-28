# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils flag-o-matic

DESCRIPTION="Client Library for accessing the latest XML based MusicBrainz web service"
HOMEPAGE="https://musicbrainz.org/doc/libmusicbrainz"


COMMIT="8be45b12a86bc0e46f2f836c8ac88e1e98d82aee"
SRC_URI="https://github.com/metabrainz/lib${PN}/archive/${COMMIT}.tar.gz -> lib${PN}-20180413.tar.gz"

LICENSE="LGPL-2.1"
SLOT="5/1"	# soname of libmusicbrainz5.so
KEYWORDS="~alpha amd64 arm arm64 ~hppa ~ia64 ppc ppc64 sparc x86 ~amd64-linux ~x86-linux"
IUSE="examples test"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-libs/libxml2
	net-libs/neon
"
DEPEND="${RDEPEND}
	test? ( dev-util/cppunit )
"

S="${WORKDIR}/lib${PN}-${COMMIT}"

src_prepare() {
	use test || cmake_comment_add_subdirectory tests
	cmake-utils_src_prepare
}

src_configure() {
	# bug 619668
	append-cxxflags -std=c++14

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	if use examples; then
		docinto examples
		dodoc examples/*.{c,cc,txt}
		docompress -x /usr/share/doc/${PF}/examples
	fi
}
