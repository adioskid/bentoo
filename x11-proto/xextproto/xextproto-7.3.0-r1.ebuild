# Distributed under the terms of the GNU General Public License v2
EAPI=6

inherit multilib-minimal

DESCRIPTION="X.Org Protocol ${proto} package stub ."

KEYWORDS="*"

SLOT="0/stub"

PDEPEND="|| (
	=x11-base/xorg-proto-2018.4_p20180627-r2
	=x11-base/xorg-proto-2020.1 )"
DEPEND="${RDEPEND}"

S="${WORKDIR}"

multilib_src_configure() { return 0; }
src_configure() { return 0; }
multilib_src_compile() { return 0; }
src_compile() { return 0; }
multilib_src_install() { return 0; }
src_install() { return 0; }
