# Copyright 2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )
inherit python-r1 xorg-3

DESCRIPTION="QEMU QXL paravirt video driver"

KEYWORDS="~amd64 ~x86"
IUSE="xspice"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	xspice? (
		app-emulation/spice
		${PYTHON_DEPS}
	)
	x11-base/xorg-server[-minimal]
	>=x11-libs/libdrm-2.4.46"
DEPEND="${RDEPEND}
	>=app-emulation/spice-protocol-0.12.0
	x11-base/xorg-proto"

PATCHES=(
	"${FILESDIR}/${PN}-worst-hack-of-all-time-to-qxl-driver.patch" # From Fedora
	"${FILESDIR}/${P}-xspice-use-print-instead-of-print.patch" # Python 3 support from master
	"${FILESDIR}/${P}-xspice-remove-extra-space-before-assignment.patch" # Python 3 support from master
	"${FILESDIR}/${P}-xspice-fix-python3-str-vs-bytes-confusion.patch" # Python 3 support from master
	"${FILESDIR}/${P}-xspice-adjust-shebang-to-explicitly-mention-python3.patch" # Python 3 support from master
	"${FILESDIR}/${P}-modesetting-validate-the-atom-for-enum-properties.patch" # From master
	"${FILESDIR}/${P}-qxl-call-provider-init.patch" # From master
	"${FILESDIR}/${P}-make-output-name-numbering-1-based.patch" # From master
	"${FILESDIR}/${P}-make-output-names-match-modesetting-driver.patch" # From master
	"${FILESDIR}/${P}-qxl-initialize-prev-field-while-dup-surface-list.patch" # From master
	"${FILESDIR}/${P}-correct-a-long-standing-led-state-bug-in-xspice.patch" # From master
	"${FILESDIR}/${P}-qxl-include-only-the-dpms-headers-we-need.patch" # From master
	"${FILESDIR}/${PN}-avoid-crashing-xserver-on-previous-active-vt-when-shutting-down-this-xserver.patch" # Upstream bug 99102
	"${FILESDIR}/${PN}-kms-call-leavevt-on-shutdown.patch"
)

src_configure() {
	XORG_CONFIGURE_OPTIONS=(
		$(use_enable xspice)
	)
	xorg-3_src_configure
}
