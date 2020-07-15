# Distributed under the terms of the GNU General Public License v2

# XXX: the tarball here is just the kernel modules split out of the binary
#      package that comes from virtualbox-bin

EAPI=7

inherit linux-mod user

DESCRIPTION="Kernel Modules for Virtualbox"
HOMEPAGE="https://www.virtualbox.org/"
SRC_URI="https://download.virtualbox.org/virtualbox/6.1.12/VirtualBox-6.1.12-139181-Linux_amd64.run"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="pax_kernel"

RDEPEND="!=app-emulation/virtualbox-9999"

S="${WORKDIR}/vboxhost"

BUILD_TARGETS="all"
BUILD_TARGET_ARCH="${ARCH}"
MODULE_NAMES="vboxdrv(misc:${S}) vboxnetflt(misc:${S}) vboxnetadp(misc:${S})"
MODULESD_VBOXDRV_ENABLED="yes"
MODULESD_VBOXNETADP_ENABLED="no"
MODULESD_VBOXNETFLT_ENABLED="no"

src_unpack() {
	sh ${DISTDIR}/${A} --noexec --keep --nox11 || die
	cd install && tar -xaf VirtualBox.tar.bz2
	mv src/vboxhost ${WORKDIR}
}

pkg_setup() {
	enewgroup vboxusers
	linux-mod_pkg_setup
	BUILD_PARAMS="CC=$(tc-getBUILD_CC) KERN_DIR=${KV_DIR} KERN_VER=${KV_FULL} O=${KV_OUT_DIR} V=1 KBUILD_VERBOSE=1"
}

src_prepare() {
	if use pax_kernel && kernel_is -ge 3 0 0 ; then
		eapply -p0 "${FILESDIR}"/${PN}-5.2.8-pax-const.patch
	fi

	default
}

src_install() {
	linux-mod_src_install
	insinto /usr/lib/modules-load.d/
	doins "${FILESDIR}"/virtualbox.conf
}

pkg_postinst() {
	# Remove vboxpci.ko from current running kernel
	find /lib/modules/${KV_FULL}/misc -type f -name "vboxpci.ko" -delete
	linux-mod_pkg_postinst
}