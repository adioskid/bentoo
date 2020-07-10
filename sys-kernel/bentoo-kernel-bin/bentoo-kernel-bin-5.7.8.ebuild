# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit

DESCRIPTION="Image and modules from bentoo sources(gentoo-sources fork)"
HOMEPAGE=""
SRC_URI+="https://binhost.bentoo.info/distfiles/kernel-${PV}.tar.xz -> ${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
IUSE="+backup clean"


RDEPEND="
	app-arch/xz-utils
	sys-kernel/genkernel-next
	x11-drivers/nvidia-drivers
	x11-drivers/nvidia-kernel-modules
	app-emulation/virtualbox-guest-additions
	app-emulation/open-vm-tools
	sys-kernel/linux-firmware
	sys-firmware/intel-microcode
	sys-apps/iucode_tool
"
S="${WORKDIR}"

src_unpack() {
	unpack ${A}
}

src_install() {
	insinto /boot/
	doins -r boot/*

	insinto /lib/modules/
	doins -r lib/modules/*
}

pkg_preinst() {

	check_kernel() {
		vmlinuz=$(ls /boot/vmlinuz-${PV}-bentoo)
	}

	check_initramfs() {
		initramfs=$(ls /boot/initramfs-${PV}-bentoo)
	}

	check_modules() {
		modules=$(ls /lib/modules/${PV}-bentoo)
	}

	if [ -n check_kernel && check_initramfs && check_modules ];
	then
		ewarn "That package will reinstall the current version kernel."
		if use backup;
		then
			# rename old files -> *.old
			find /boot -name *-${PV}-bentoo | sed -e "p;s/${PV}-bentoo/${PV}-bentoo-old/" | xargs -n2 mv
			find /lib/modules -name ${PV}-bentoo | sed -e "p;s/${PV}-bentoo/${PV}-bentoo-old/" | xargs -n2 mv
		elif use clean;
		then 
			# remove old files
			rm /boot/*-${PV}-bentoo
			rm -rf /lib/modules/${PV}-bentoo
		fi
	fi

}

pkg_postinst() {
	kernel-2_pkg_postinst
	elog "A new version of image, initramfs, microcodes and modules are installed."
}

pkg_postrm() {
	kernel-2_pkg_postrm
}
