# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit

DESCRIPTION="Image and modules from bentoo sources(gentoo-sources fork)"
HOMEPAGE=""
SRC_URI+="https://binhost.bentoo.info/distfiles/kernel-${PV}.tar.xz -> ${P}.tar.xz"

KEYWORDS="amd64"
LICENSE="GPL-2"
SLOT="0"
IUSE="+backup clean initramfs microcodes nvidia vbox-guest vmware-guest"

RDEPEND="
	app-arch/tar
	app-arch/xz-utils
	app-arch/zstd
	sys-kernel/linux-firmware
	sys-firmware/intel-microcode
	sys-apps/iucode_tool
	initramfs? ( sys-kernel/genkernel-next )
	nvidia? (
		x11-drivers/nvidia-drivers
		x11-drivers/nvidia-kernel-modules
	)
	vbox-guest? ( app-emulation/virtualbox-guest-additions )
	vmware-guest? ( app-emulation/open-vm-tools )
"
S="${WORKDIR}"

src_unpack() {
	unpack ${A}
}

src_install() {

	insinto /boot/
	doins -r boot/*-${PV}-bentoo

	if use microcodes;
	then
		doins boot/amd-uc.img
		doins boot/intel-uc.img
		doins boot/early_ucode.cpio
	fi

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

		if !use nvidia;
		then
			rm -rf /lib/modules/5.7.6-bentoo/video
		fi

		if !use vbox-guest;
		then
			rm -rf /lib/modules/5.7.6-bentoo/misc/vbox*
		fi

		if !use vmware-guest;
		then
			rm -rf /lib/modules/5.7.6-bentoo/misc/vm*
		fi

	kernel-2_pkg_postinst
	elog "A new version of image, initramfs, microcodes and modules are installed."

}

pkg_postrm() {
	kernel-2_pkg_postrm
}
