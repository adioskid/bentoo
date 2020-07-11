# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit

DESCRIPTION="Image and modules from bentoo sources(gentoo-sources fork)"
HOMEPAGE=""
SRC_URI+="https://binhost.bentoo.info/distfiles/kernel-${PV}.tar.xz -> ${P}.tar.xz"

KEYWORDS="amd64"
LICENSE="GPL-2"
SLOT="0"
IUSE="+amd +backup clean +initramfs +intel microcode nvidia +symlink vbox-guest vmware-guest"

RDEPEND="
	app-arch/tar
	app-arch/xz-utils
	app-arch/zstd
	microcode? (
		intel? ( sys-firmware/intel-microcode
							sys-apps/iucode_tool
						)
		amd? ( sys-kernel/linux-firmware )
	)
	initramfs? ( sys-kernel/genkernel-next )
	nvidia? (
		x11-drivers/nvidia-drivers
		x11-drivers/nvidia-kernel-modules
	)
	vbox-guest? ( app-emulation/virtualbox-guest-additions )
	vmware-guest? ( app-emulation/open-vm-tools )
"
QA_PREBUILT='*'

S="${WORKDIR}"

src_unpack() {
	unpack ${A}
}

src_install() {

	insinto /boot/
	doins -r boot/config-${PV}-bentoo
	doins -r boot/System.map-${PV}-bentoo
	doins -r boot/vmlinuz-${PV}-bentoo

	if use initramfs;
	then
		doins -r boot/initramfs-${PV}-bentoo
	fi

	if use microcode;
	then
		if use amd;
		then
			doins boot/amd-uc.img
		elif use intel;
		then
			doins boot/intel-uc.img
			doins boot/early_ucode.cpio
		fi
	fi

	insinto /lib/modules/
	doins -r lib/modules/*

}

pkg_preinst() {

	if !use nvidia;
	then
		rm -rf ${S}/lib/modules/5.7.6-bentoo/video
	fi

	if !use vbox-guest;
	then
		rm -rf ${S}/lib/modules/5.7.6-bentoo/misc/vbox*
	fi

	if !use vmware-guest;
	then
		rm -rf ${S}/lib/modules/5.7.6-bentoo/misc/vm*
	fi

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

	elog "A new version of image, initramfs, microcode and modules are installed."

	if use symlink;
	then
		ego boot update
		elog "The new kernel was updated on grub boot menu."
	fi

}
