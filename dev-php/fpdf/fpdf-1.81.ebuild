# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# shellcheck disable=SC2034

EAPI=7

MY_PV="$(ver_rs 1 '')"
MY_P="${PN}${MY_PV}"

DESCRIPTION="FPDF is a PHP class which allows to generate PDF files with pure PHP"
HOMEPAGE="http://www.fpdf.org/"
SRC_URI="http://www.fpdf.org/en/dl.php?v=${MY_PV}&f=tgz -> ${MY_P}.tgz"

LICENSE="freedist"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

RDEPEND="dev-lang/php:*[gd,zlib]"

S="${WORKDIR}/${MY_P}"

DOCS=( install.txt )

src_install() {
		insinto "/usr/share/php/${PN}"
		doins -r ./*.php font/ makefont/

		if use doc; then
			docinto html
			dodoc -r changelog.htm fpdf.css FAQ.htm html/ tutorial/
		fi
}
