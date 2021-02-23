# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7,8,9} )

inherit distutils-r1 xdg

DESCRIPTION="Securely and anonymously send and receive files over Tor"
HOMEPAGE="https://onionshare.org/"
SRC_URI="https://github.com/micahflee/onionshare/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="nautilus test"

RESTRICT="!test? ( test )"

DEPEND="${PYTHON_DEPS}
	test? ( dev-python/pycryptodome[${PYTHON_USEDEP}]
		dev-python/PyQt5[${PYTHON_USEDEP},testlib]
		dev-python/pytest[${PYTHON_USEDEP}] )"
RDEPEND="${PYTHON_DEPS}
	dev-python/flask[${PYTHON_USEDEP}]
	>=dev-python/flask-httpauth-3.2.4[${PYTHON_USEDEP}]
	dev-python/pycryptodome[${PYTHON_USEDEP}]
	dev-python/PyQt5[${PYTHON_USEDEP}]
	dev-python/PySocks[${PYTHON_USEDEP}]
	>=net-libs/stem-1.6.0[${PYTHON_USEDEP}]
	>=net-vpn/tor-0.2.7.1
	nautilus? ( dev-python/nautilus-python )"

PATCHES=(
	"${FILESDIR}"/2.2-org.onionshare.OnionShare.desktop-fix-StartupWMClass.patch
	"${FILESDIR}"/2.2-scripts-onionshare-nautilus.py-use-python3.patch
)

python_test() {
	${EPYTHON} -m pytest tests/ || die
}
