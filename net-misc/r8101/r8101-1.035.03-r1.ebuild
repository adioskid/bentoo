# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit linux-info linux-mod

DESCRIPTION="Driver for Realtek 810x/840x based PCI-E/PCI Ethernet Cards (PCI_ID 10ec:8136)"
HOMEPAGE="http://www.realtek.com.tw/downloads/downloadsView.aspx?Langid=1&PNid=14&PFid=7&Level=5&Conn=4&DownTypeID=3&GetDown=false#2"
SNAPSHOT_COMMIT="b79c681ef5c0e20e5a3c7058986b3e5f27178769"
SRC_URI="https://github.com/ghostrider-reborn/realtek-r8101-linux-driver/archive/${SNAPSHOT_COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
IUSE="binhost"
KEYWORDS="*"

MODULE_NAMES="r8101(net:${S}/src)"
BUILD_TARGETS="modules"

CONFIG_CHECK="!R8169"
ERROR_R8169="${P} requires Realtek 8169 PCI Gigabit Ethernet adapter (CONFIG_R8169) to be DISABLED"

S="${WORKDIR}/realtek-r8101-linux-driver-${SNAPSHOT_COMMIT}"

pkg_setup() {
    linux-mod_pkg_setup
    BUILD_PARAMS="KERNELDIR=${KV_DIR}"
}

src_install() {
	linux-mod_src_install
	einstalldocs
}

