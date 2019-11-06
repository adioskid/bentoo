# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit eutils versionator

SLOT="0"

if [ $(get_version_component_range 3) -eq 0 ]; then
	MY_PV="$(get_version_component_range 1-2)"
else
	MY_PV="$(get_version_component_range 1-3)"
fi

MY_BV="$(get_version_component_range 4-6)"
MY_PN="idea"

RESTRICT="strip"
QA_TEXTRELS="opt/${PN}-${MY_PV}/bin/libbreakgen.so"
QA_PRESTRIPPED="opt/${PN}-${MY_PV}/lib/libpty/linux/x86/libpty.so
	opt/${PN}-${MY_PV}/lib/libpty/linux/x86_64/libpty.so
	opt/${PN}-${MY_PV}/bin/libyjpagent-linux.so
	opt/${PN}-${MY_PV}/bin/libyjpagent-linux64.so"
QA_WX_LOAD="
	opt/${PN}-${MY_PV}/bin/fsnotifier-arm
	opt/${PN}-${MY_PV}/plugins/tfsIntegration/lib/native/linux/ppc/libnative_auth.so
	opt/${PN}-${MY_PV}/plugins/tfsIntegration/lib/native/linux/ppc/libnative_console.so
	opt/${PN}-${MY_PV}/plugins/tfsIntegration/lib/native/linux/ppc/libnative_filesystem.so
	opt/${PN}-${MY_PV}/plugins/tfsIntegration/lib/native/linux/ppc/libnative_misc.so
	opt/${PN}-${MY_PV}/plugins/tfsIntegration/lib/native/linux/ppc/libnative_synchronization.so
	opt/${PN}-${MY_PV}/plugins/tfsIntegration/lib/native/solaris/sparc/libnative_auth.so
	opt/${PN}-${MY_PV}/plugins/tfsIntegration/lib/native/solaris/sparc/libnative_console.so
	opt/${PN}-${MY_PV}/plugins/tfsIntegration/lib/native/solaris/sparc/libnative_filesystem.so
	opt/${PN}-${MY_PV}/plugins/tfsIntegration/lib/native/solaris/sparc/libnative_misc.so
	opt/${PN}-${MY_PV}/plugins/tfsIntegration/lib/native/solaris/sparc/libnative_synchronization.so
	opt/${PN}-${MY_PV}/plugins/tfsIntegration/lib/native/solaris/x86/libnative_auth.so
	opt/${PN}-${MY_PV}/plugins/tfsIntegration/lib/native/solaris/x86/libnative_console.so
	opt/${PN}-${MY_PV}/plugins/tfsIntegration/lib/native/solaris/x86/libnative_filesystem.so
	opt/${PN}-${MY_PV}/plugins/tfsIntegration/lib/native/solaris/x86/libnative_misc.so
	opt/${PN}-${MY_PV}/plugins/tfsIntegration/lib/native/solaris/x86/libnative_synchronization.so"

DESCRIPTION="IntelliJ IDEA is an intelligent Java IDE (Community Edition)"
HOMEPAGE="http://jetbrains.com/idea/"
SRC_URI="http://download.jetbrains.com/${MY_PN}/${MY_PN}IC-${MY_PV}.tar.gz"
LICENSE="Apache-2.0"
IUSE="-custom-jdk"
KEYWORDS="amd64 x86"

REQUIRED_USE="!amd64? ( !custom-jdk )"

RDEPEND="!custom-jdk? ( >=virtual/jdk-1.7 )"

S="${WORKDIR}/${MY_PN}-IC-${MY_BV}"

src_prepare() {
	if ! use amd64; then
		rm -rf plugins/tfsIntegration/lib/native/linux/x86_64
	fi
	if ! use arm; then
		rm bin/fsnotifier-arm
		rm -rf plugins/tfsIntegration/lib/native/linux/arm
	fi
	if ! use ppc; then
		rm -rf plugins/tfsIntegration/lib/native/linux/ppc
	fi
	if ! use x86; then
		rm -rf plugins/tfsIntegration/lib/native/linux/x86
	fi
	if ! use custom-jdk; then
		if [[ -d jre64 ]]; then
			rm -r jre64 || die
		fi
	fi
	rm -rf plugins/tfsIntegration/lib/native/solaris
	rm -rf plugins/tfsIntegration/lib/native/hpux
}

#pkg_postinst() {
#               echo 
#               echo "This is EAP Intellij Idea 15"
#               echo        
#}
src_install() {
	local dir="/opt/${PN}-${MY_PV}"

	insinto "${dir}"
	doins -r *

	if use custom-jdk; then
		if [[ -d jre64 ]]; then
			fperms -R 755 ${dir}/jre64/bin
		fi
	fi

	fperms 755 "${dir}/bin/${MY_PN}.sh" "${dir}/bin/fsnotifier" "${dir}/bin/fsnotifier64"

	newicon "bin/idea.png" "${PN}.png"
	make_wrapper ${PN} ${dir}/bin/${MY_PN}.sh
        # recommended by: https://confluence.jetbrains.com/display/IDEADEV/Inotify+Watches+Limit
	mkdir -p "${D}/etc/sysctl.d/"
	echo "fs.inotify.max_user_watches = 524288" > "${D}/etc/sysctl.d/30-idea-inotify-watches.conf"

	make_desktop_entry ${PN} "IntelliJ IDEA(Community Edition)" ${PN} "Development;IDE"
}
