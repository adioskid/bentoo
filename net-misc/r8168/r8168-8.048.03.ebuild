# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit linux-info linux-mod eutils

DESCRIPTION="GBE Ethernet LINUX driver r8168 for kernel up to 5.6"
HOMEPAGE="https://www.realtek.com/en/component/zoo/category/network-interface-controllers-10-100-1000m-gigabit-ethernet-pci-express-software"

GITHUB_USER="mtorromeo"
SRC_URI="https://github.com/${GITHUB_USER}/${PN}/tarball/${PV} -> ${P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"

BUILD_TARGETS="modules"
CONFIG_CHECK="!R8169"
ERROR_R8169="${P} requires Realtek 8169 PCI Gigabit Ethernet adapter (CONFIG_R8169) to be DISABLED"

PATCHES=( "${FILESDIR}/kernel56.patch" )

pkg_setup() {
    linux-mod_pkg_setup
    BUILD_PARAMS="KERNELDIR=${KV_DIR}"
}

src_unpack() {
    unpack ${A}
    S=$(find ${WORKDIR} -iname "${GITHUB_USER}-${PN}-*")
    MODULE_NAMES="r8168(net:${S}/src)"
}

src_install() {
    linux-mod_src_install
    dodoc README
}
