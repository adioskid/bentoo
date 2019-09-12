# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eapi7-ver eutils flag-o-matic linux-info linux-mod user udev

DESCRIPTION="VMware kernel modules"
HOMEPAGE="http://www.vmware.com/"

SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND=""
DEPEND="
	=app-emulation/vmware-workstation-14.$(ver_cut 2-3)*
"

S=${WORKDIR}

pkg_setup() {
	CONFIG_CHECK="~HIGH_RES_TIMERS"
	if kernel_is ge 2 6 37 && kernel_is lt 2 6 39; then
		CONFIG_CHECK="${CONFIG_CHECK} BKL"
	fi
	CONFIG_CHECK="${CONFIG_CHECK} VMWARE_VMCI VMWARE_VMCI_VSOCKETS"

	linux-info_pkg_setup
	linux-mod_pkg_setup

	VMWARE_GROUP=${VMWARE_GROUP:-vmware}

	VMWARE_MODULE_LIST="vmmon vmnet"

	VMWARE_MOD_DIR="${PN}-${PVR}"

	BUILD_TARGETS="auto-build KERNEL_DIR=${KERNEL_DIR} KBUILD_OUTPUT=${KV_OUT_DIR}"

	enewgroup "${VMWARE_GROUP}"

	filter-flags -mfpmath=sse -mavx -mpclmul -maes
	append-cflags -mno-sse  # Found a problem similar to bug #492964

	for mod in ${VMWARE_MODULE_LIST}; do
		MODULE_NAMES="${MODULE_NAMES} ${mod}(misc:${S}/${mod}-only)"
	done
}

src_unpack() {
	cd "${S}"
	for mod in ${VMWARE_MODULE_LIST}; do
		tar -xf /opt/vmware/lib/vmware/modules/source/${mod}.tar
	done
}

src_prepare() {
	# from https://github.com/mkubecek/vmware-host-modules/tree/workstation-14.1.5
	kernel_is ge 4 9 0 && epatch "${FILESDIR}/4.09-00-vmnet-use-standard-definition-of-PCI_VENDOR_ID_VMWAR.patch"
	kernel_is ge 4 10 0 && epatch "${FILESDIR}/4.10-00-vmnet-use-standard-definition-of-PCI_VENDOR_ID_VMWAR.patch"
	kernel_is ge 4 12 0 && epatch "${FILESDIR}/4.12-00-vmmon-use-standard-definition-of-MSR_MISC_FEATURES_E.patch"
	kernel_is ge 4 13 0 && epatch "${FILESDIR}/4.13-00-vmmon-use-standard-definition-of-CR3_PCID_MASK-if-av.patch"
	epatch "${FILESDIR}/00-vmmon-quick-workaround-for-objtool-warnings.patch"
	kernel_is ge 4 16 0 && epatch "${FILESDIR}/4.16-00-vmmon-use-standard-definition-of-MSR_K7_HWCR_SMMLOCK.patch"
	epatch "${FILESDIR}/01-vmmon-fix-always_inline-attribute-usage.patch"
	epatch "${FILESDIR}/02-vmmon-fix-indirect-call-with-retpoline-build.patch"
	epatch "${FILESDIR}/03-vmmon-check-presence-of-file_operations-poll.patch"
	epatch "${FILESDIR}/04-modules-replace-SUBDIRS-with-M.patch"
	epatch "${FILESDIR}/05-vmmon-totalram_pages-is-a-function-since-5.0.patch"
	epatch "${FILESDIR}/06-vmmon-bring-back-the-do_gettimeofday-helper.patch"
	epatch "${FILESDIR}/07-modules-handle-access_ok-with-two-arguments.patch"
	epatch "${FILESDIR}/08-vmmon-use-KERNEL_DS-rather-than-get_ds.patch"
	epatch "${FILESDIR}/09-vmmon-fix-return-type-of-vm_operations_struct-fault-.patch"

	# decouple the kernel include dir from the running kernel version: https://github.com/stefantalpalaru/gentoo-overlay/issues/17
	sed -i -e "s%HEADER_DIR = /lib/modules/\$(VM_UNAME)/build/include%HEADER_DIR = ${KERNEL_DIR}/include%" */Makefile || die "sed failed"

	# Allow user patches so they can support RC kernels and whatever else
	default
}

src_install() {
	linux-mod_src_install
	local udevrules="${T}/60-vmware.rules"
	cat > "${udevrules}" <<-EOF
		KERNEL=="vmci",  GROUP="vmware", MODE="660"
		KERNEL=="vmw_vmci",  GROUP="vmware", MODE="660"
		KERNEL=="vmmon", GROUP="vmware", MODE="660"
		KERNEL=="vsock", GROUP="vmware", MODE="660"
	EOF
	udev_dorules "${udevrules}"

	dodir /etc/modprobe.d/

	cat > "${D}"/etc/modprobe.d/vmware.conf <<-EOF
		# Support for vmware vmci in kernel module
		alias vmci	vmw_vmci
	EOF

	export installed_modprobe_conf=1
	dodir /etc/modprobe.d/
	cat >> "${D}"/etc/modprobe.d/vmware.conf <<-EOF
		# Support for vmware vsock in kernel module
		alias vsock	vmw_vsock_vmci_transport
	EOF

	export installed_modprobe_conf=1
}

pkg_postinst() {
	linux-mod_pkg_postinst
	ewarn "Don't forget to run '/etc/init.d/vmware restart' to use the new kernel modules."
}
