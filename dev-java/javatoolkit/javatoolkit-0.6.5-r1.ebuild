# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8,9} )
PYTHON_REQ_USE="xml(+)"
DISTUTILS_USE_SETUPTOOLS=no

inherit distutils-r1 prefix

DESCRIPTION="Collection of Gentoo-specific tools for Java"
HOMEPAGE="https://wiki.gentoo.org/wiki/Project:Java"
SRC_URI="https://gitweb.gentoo.org/proj/${PN}.git/snapshot/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

python_prepare_all() {
	hprefixify src/py/buildparser src/py/findclass setup.py
	distutils-r1_python_prepare_all
}

python_install() {
	distutils-r1_python_install \
		--install-scripts="${EPREFIX}"/usr/libexec/${PN}
}

pkg_postinst() {
	mkdir -p /usr/lib/${PN}/bin
	ln -sf /usr/libexec/${PN}/* /usr/lib/${PN}/bin/
}

pkg_postrm() {
	rm -rf /usr/lib/${PN}
}