# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop eutils pax-utils xdg

MY_PN="${PN/-bin/}"

DESCRIPTION="Supercharge your API workflow"
HOMEPAGE="https://www.postman.com"
SRC_URI="https://dl.pstmn.io/download/latest/linux64 -> postman-bin-8.2.3.tar.gz"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="pax_kernel"
RESTRICT="mirror strip"

DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_PN^}/app"

src_prepare() {
	mv _Postman Postman
	default
}

src_install() {
	local dir="/opt/${PN}"

	insinto "${dir}"
	doins -r *
	fperms 755 "${dir}"/Postman

	make_wrapper "${PN}" "${dir}/Postman"
	newicon "resources/app/assets/icon.png" "${PN}.png"
	make_desktop_entry "${PN}" "Postman" "${PN}" "Development;IDE;"

	use pax_kernel && pax-mark m "${ED}/opt/${MY_PN}/${MY_PN^}"
}