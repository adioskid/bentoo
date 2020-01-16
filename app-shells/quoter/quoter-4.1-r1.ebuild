# Copyright 2016-2018 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit toolchain-funcs

DESCRIPTION="Quote arguments or standard input for usage in POSIX shell by eval"
HOMEPAGE="https://github.com/vaeth/quoter/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x64-cygwin ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

src_compile() {
	emake CC="$(tc-getCC)" EPREFIX="${EPREFIX}"
}

src_install() {
	emake DESTDIR="${ED}" EPREFIX="${EPREFIX}" install
	dodoc README.md
}
