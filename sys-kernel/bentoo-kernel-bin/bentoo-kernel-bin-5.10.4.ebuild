# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit

distfile="https://binhost.bentoo.info/distfiles"

DESCRIPTION="Image and modules from bentoo sources(gentoo-sources fork)"
SRC_URI="
	${distfile}/${P}.tar.xz
	source? ( ${distfile}/bentoo-sources-bin-${PV}.tar.xz )
	"
KEYWORDS="amd64"
LICENSE="GPL-2"
SLOT="0"
IUSE="+amd +backup clean +grub +initramfs +intel +microcode +nvidia source"

RESTRICT="splitdebug mirror"

RDEPEND="
	app-arch/tar
	app-arch/xz-utils
	initramfs? ( sys-kernel/genkernel-next )
	microcode? (
		!intel? (
			amd? ( sys-kernel/linux-firmware )
		)
		intel? (
			sys-apps/iucode_tool
			sys-firmware/intel-microcode
		)
	)
	nvidia? (
		x11-drivers/nvidia-drivers
		x11-drivers/nvidia-kernel-modules
	)
"
QA_PREBUILT='*'

S=${WORKDIR}

src_unpack() {

	if use source;
	then
		unpack ${P}.tar.xz
		mkdir source
		cd source && unpack bentoo-sources-bin-${PV}.tar.xz
	else
		unpack ${A}
	fi

}

src_install() {

	# if not use nvidia card, remove the modules.
	if ! use nvidia;
	then
		rm -rf lib/modules/${PV}-bentoo/video || die
	fi

	# install kernel image.
	insinto /boot/
	mv boot/{config-${PV}-bentoo,System.map-${PV}-bentoo,vmlinuz-${PV}-bentoo} "${ED}/boot/" || die


	# install initramfs
	if use initramfs;
	then
		mv boot/initramfs-${PV}-bentoo "${ED}/boot/" || die
	fi

	# install microcode
	if use microcode;
	then
		if use amd;
		then
			mv boot/amd-uc.img "${ED}/boot/" || die
		fi
		if use intel;
		then
			mv boot/{intel-uc.img,early_ucode.cpio} "${ED}/boot/" || die
		fi
	fi

	# install modules.
	insinto /lib/modules/
	mv lib/modules/* "${ED}/lib/modules/" || die
	
	if use source;
	then
		cd source && mv * "${ED}" || die
	else
		insinto /usr/src/
		mv usr/src/* "${ED}/usr/src/" || die
	fi

	if ! use source;
	then
		# remove symlinks to sources.
		rm -rf ${D}/lib/modules/*/{source,build} || die
	fi

}

pkg_preinst() {
	
	check_kernel() {
		return vmlinuz=$(ls /boot/vmlinuz-${PV}-bentoo)
	}

	check_initramfs() {
		return initramfs=$(ls /boot/initramfs-${PV}-bentoo)
	}

	check_modules() {
		return modules=$(ls /lib/modules/${PV}-bentoo)
	}

	# check if exist all files.
	if [ check_kernel ] && [ check_initramfs ] && [ check_modules ];
	then
		if use backup && ! use clean;
		then

			# rename kernel and initramfs to old files => *.old
			find ${ROOT}/boot -name *-${PV}-bentoo | sed -e "p;s/bentoo/bentoo-old/" | xargs -n2 mv -f

			if [ ! -d "${ROOT}/lib/modules/${PV}-bentoo-old" ];
			then
				# rename kernel modules to old files => *.old
				find ${ROOT}/lib/modules -name ${PV}-bentoo | sed -e "p;s/bentoo/bentoo-old/" | xargs -n2 mv -f
			fi

			if [ ! -d "${ROOT}/usr/src/linux-${PV}-bentoo-old" ];
			then
				# rename kernel modules to old files => *.old
				find ${ROOT}/usr/src -name linux-${PV}-bentoo | sed -e "p;s/bentoo/bentoo-old/" | xargs -n2 mv -f
			fi

		elif use clean && ! use backup;
		then 
			# remove old files.
			rm ${ROOT}/boot/*-${PV}-bentoo
			rm -rf ${ROOT}/lib/modules/${PV}-bentoo

				# remove old amd microcode.
				if use amd;
				then
					rm ${ROOT}/boot/amd-uc.img
				fi

				# remove old intel microcode.
				if use intel;
				then
					rm ${ROOT}/boot/{early_ucode.cpio,intel-uc.img}
				fi

		fi
	fi

}

pkg_postinst() {

	# create a symlink to kernel source folder.
	if [ ! -e ${ROOT}/usr/src/linux ];
	then
		ln -sf linux-${PV}-bentoo ${ROOT}/usr/src/linux
	fi

	elog "A new version of image, initramfs, microcode and modules are installed."

	kernel_version=$(uname -r)

	# configure grub with new kernel replace the older.
	grub_cfg="/boot/grub/grub.cfg"

	# check kernel image.
	vmlinuz_old="vmlinuz-$kernel_version"
	vmlinuz_new="vmlinuz-${PV}-bentoo"

	initramfs_old="initramfs-$kernel_version"
	initramfs_new="initramfs-${PV}-bentoo"

	# change the entry on grub.cfg

	if use grub ;
	then
		if [ -f "${ROOT}/$grub_cfg" ];
		then

			sed -i "s/$vmlinuz_old/$vmlinuz_new/g" ${ROOT}/$grub_cfg || die

			sed -i "s/$initramfs_old/$initramfs_new/g" ${ROOT}/$grub_cfg || die

		fi
	fi
	
	# remove microcode lines if not use.
	if ! use amd ;
	then
		sed -i 's/\/amd-uc.img//g' ${ROOT}/$grub_cfg || die
	fi

	if ! use intel ;
	then
		sed -i 's/\/intel-uc.img//g' ${ROOT}/$grub_cfg || die
		sed -i 's/\/early_ucode.cpio//g' ${ROOT}/$grub_cfg || die
	fi

	ewarn "That package installed the current version of Bentoo kernel binary."

	elog "The new kernel was updated on grub boot menu."

}

pkg_postrm() {

	if [ ! -f "${ROOT}/boot/vmlinuz-${PV}-bentoo" ];
	then

		# remove kernel imagen, initramfs and microcode.
		rm -rf ${ROOT}/boot/*-${PV}-bentoo-old || die
		ewarn "Old files on /boot was removed..."

		# remove kernel modules.
		rm -rf ${ROOT}/lib/modules/${PV}-bentoo* || die
		ewarn "Old files on /lib/modules was removed..."

		# remove kernel source folder.
		rm -rf ${ROOT}/usr/src/linux-${PV}-bentoo-old || die
		ewarn "Old files on /usr/src was removed..."

		# remove kernel folder symlink.
		rm ${ROOT}/usr/src/linux || die
		ewarn "Kernel source symlink removed..."

	fi

	elog "Welcome to Bentoo"

}
