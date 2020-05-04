# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{5,6,7} )
inherit distutils-r1

MY_PN="Flask-HTTPAuth"

DESCRIPTION="Provides Basic and Digest HTTP authentication for Flask routes"
HOMEPAGE="https://github.com/miguelgrinberg/Flask-HTTPAuth https://pypi.org/project/Flask-HTTPAuth/"
SRC_URI="https://github.com/miguelgrinberg/${MY_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-python/flask[${PYTHON_USEDEP}]"

S="${WORKDIR}/${MY_PN}-${PV}"

python_test() {
	esetup.py test || die
}
