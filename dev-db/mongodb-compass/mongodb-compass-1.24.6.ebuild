# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop

MY_PV=${PV/_beta/~beta.}
MY_PN=${PN}
DESCRIPTION="The MongoDB GUI"
HOMEPAGE="https://www.mongodb.com/products/compass"

BETA_POSTFIX=""

if [[ "${PV}" == *beta* ]]; then
	MY_PN=${PN}-beta
	SRC_URI="https://downloads.mongodb.com/compass/beta/${MY_PN}_${MY_PV}_amd64.deb"
else
	SRC_URI="https://downloads.mongodb.com/compass/${PN}_${PV}_amd64.deb"
fi

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

S="${WORKDIR}"

src_unpack(){
	unpack "${A}"
	unpack ./data.tar.xz
	rm *.tar.gz debian-binary
}

src_install(){
	insinto /opt/${MY_PN}
	doins -r usr/* || die
	if [[ "${PV}" == *beta* ]]; then
		fperms +x "/opt/${MY_PN}/lib/mongodb-compass/MongoDB Compass  Beta"
		dosym "/opt/${MY_PN}/lib/mongodb-compass/MongoDB Compass  Beta" /usr/bin/${MY_PN}
	else
		fperms +x "/opt/${MY_PN}/lib/mongodb-compass/MongoDB Compass"
		dosym "/opt/${MY_PN}/lib/mongodb-compass/MongoDB Compass" /usr/bin/${MY_PN}
	fi
	newicon usr/share/pixmaps/${MY_PN}.png ${MY_PN}.png
	domenu usr/share/applications/${MY_PN}.desktop
}
