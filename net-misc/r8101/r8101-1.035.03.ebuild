# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit linux-info linux-mod eutils

DESCRIPTION="Driver for Realtek 810x/840x based PCI-E/PCI Ethernet Cards (PCI_ID 10ec:8136)"
HOMEPAGE="http://www.realtek.com.tw/downloads/downloadsView.aspx?Langid=1&PNid=14&PFid=7&Level=5&Conn=4&DownTypeID=3&GetDown=false#2"

SRC_URI="https://binhost.bentoo.info/distfiles/r8101-1.035.03.tar.bz2"

LICENSE=""
SLOT="0"
KEYWORDS="*"

BUILD_TARGETS="modules"
CONFIG_CHECK="!R8169"
ERROR_R8169="${P} requires Realtek 8169 PCI Gigabit Ethernet adapter (CONFIG_R8169) to be DISABLED"

pkg_setup() {
    linux-mod_pkg_setup
    BUILD_PARAMS="KERNELDIR=${KV_DIR}"
}

src_unpack() {
    unpack ${A}
    S=$(find ${WORKDIR} -iname "${GITHUB_USER}-${PN}-*")
    MODULE_NAMES="r8101(net/ethernet::src)"
}

src_install() {
    linux-mod_src_install
    dodoc readme
}

