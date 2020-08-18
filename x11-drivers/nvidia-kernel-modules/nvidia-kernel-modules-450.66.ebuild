# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit eutils flag-o-matic linux-info linux-mod multilib-minimal nvidia-driver \
	portability toolchain-funcs unpacker user udev

DESCRIPTION="NVIDIA GPU Kernel Modules"
HOMEPAGE="http://www.nvidia.com/ http://www.nvidia.com/Download/Find.aspx"
SRC_URI=""

LICENSE="GPL-2 NVIDIA-r2"
SLOT="0/${PV%.*}"
KEYWORDS="-* ~amd64 ~amd64-fbsd"
RESTRICT="bindist"

IUSE="kernel_FreeBSD kernel_linux"

if [ ${PV%%.*} -ge 364 ] ; then
	IUSE="${IUSE} +kms +uvm"
elif [ ${PV%%.*} -ge 331 ] ; then
	IUSE="${IUSE} uvm"
fi

DEPEND="
	=x11-drivers/nvidia-drivers-${PV}*
	kernel_linux? ( virtual/linux-sources )
"
NVDRIVERS_DIR="${EPREFIX}/opt/nvidia/nvidia-drivers-${PV}"
S="${WORKDIR}/kernel-modules"

# Maximum supported kernel version in form major.minor
: "${NV_MAX_KERNEL_VERSION:=5.7}"


nvidia_drivers_versions_check() {
	if use kernel_linux && kernel_is ge ${NV_MAX_KERNEL_VERSION%%.*} ${NV_MAX_KERNEL_VERSION#*.}; then
		ewarn "These NVIDIA kernel modules are designed to work with Linux ${NV_MAX_KERNEL_VERSION} or earlier."
	fi

	# Since Nvidia ships many different series of drivers, we need to give the user
	# some kind of guidance as to what version they should install. This tries
	# to point the user in the right direction but can't be perfect. check
	# nvidia-driver.eclass
	nvidia-driver-check-warning

	# Kernel features/options to check for
	CONFIG_CHECK="~ZONE_DMA ~MTRR ~SYSVIPC ~!LOCKDEP"
	use x86 && CONFIG_CHECK+=" ~HIGHMEM"

	# Now do the above checks
	use kernel_linux && check_extra_config
}

pkg_pretend() {
	nvidia_drivers_versions_check
}

pkg_setup() {
	# Check our config is good.
	nvidia_drivers_versions_check

	# Try to turn off distcc and ccache for people that have a problem with it.
	export DISTCC_DISABLE=1
	export CCACHE_DISABLE=1

	# Run linux-specific setup.
	use kernel_linux && pkg_setup_linux
}

pkg_setup_linux() {

	MODULE_NAMES="nvidia(video:${S})"

	# Directory structure changed somewhere between 340 and 390, probably ad 364 when the drm/kms stuff was added.
	if [ ${PV%%.*} -ge 364 ] ; then
		use_if_iuse uvm && MODULE_NAMES+=" nvidia-uvm(video:${S})"
	else
		use_if_iuse uvm && MODULE_NAMES+=" nvidia-uvm(video:${S}/uvm)"
	fi

	use_if_iuse kms && MODULE_NAMES+=" nvidia-modeset(video:${S}) nvidia-drm(video:${S})"

	# This needs to run after MODULE_NAMES (so that the eclass checks
	# whether the kernel supports loadable modules) but before BUILD_PARAMS
	# is set (so that KV_DIR is populated).
	linux-mod_pkg_setup

	BUILD_PARAMS="IGNORE_CC_MISMATCH=yes V=1 SYSSRC=${KV_DIR} \
		SYSOUT=${KV_OUT_DIR} CC=$(tc-getBUILD_CC) NV_VERBOSE=1"

	# linux-mod_src_compile calls set_arch_to_kernel, which
	# sets the ARCH to x86 but NVIDIA's wrapping Makefile
	# expects x86_64 or i386 and then converts it to x86
	# later on in the build process
	BUILD_FIXES="ARCH=$(uname -m | sed -e 's/i.86/i386/')"

	if kernel_is lt 2 6 9; then
		eerror "You must build this against 2.6.9 or higher kernels."
	fi

}

src_unpack() {
	cp -r "${NVDRIVERS_DIR}/src/kernel-modules" "${S}" || die
}


src_prepare() {

	# Apply patches for our exact package and version
	local mypatch
	for mypatch in "${FILESDIR}"/${P}*.patch ; do
		[ "${mypatch}" = "${FILESDIR}/${P}*.patch" ] && break
		eapply "${mypatch}"
	done

	default

}

src_compile() {
	# This is already the default on Linux, as there's no toplevel Makefile, but
	# on FreeBSD there's one and triggers the kernel module build, as we install
	# it by itself, pass this.

	cd "${NV_SRC}"
	if use kernel_FreeBSD; then
		MAKE="$(get_bmake)" CFLAGS="-Wno-sign-compare" emake CC="$(tc-getCC)" \
			LD="$(tc-getLD)" LDFLAGS="$(raw-ldflags)" || die
	elif use kernel_linux; then
		MAKEOPTS=-j1 linux-mod_src_compile
	fi
}


src_install() {
	if use kernel_linux; then
		src_install_linux
	elif use kernel_FreeBSD; then
		src_install_freebsd
	fi

	is_final_abi || die "failed to iterate through all ABIs"

	readme.gentoo_create_doc
}

src_install_linux() {
		linux-mod_src_install

		# Add the aliases
		# This file is tweaked with the appropriate video group in
		# pkg_preinst, see bug #491414
		insinto /etc/modprobe.d
		newins "${FILESDIR}"/nvidia.conf.modprobe-r1 nvidia.conf
		newins "${FILESDIR}"/nvidia-rmmod.conf.modprobe nvidia-rmmod.conf

		# Ensures that our device nodes are created when not using X
		sed -e 's:/opt/bin:'"${NVDRIVERS_DIR}"'/bin:g' "${FILESDIR}/nvidia-udev.sh" > "${T}/nvidia-udev.sh"
		exeinto "$(get_udevdir)"
		doexe "${T}"/nvidia-udev.sh
		udev_newrules "${FILESDIR}"/nvidia.udev-rule 99-nvidia.rules
}

src_install_freebsd() {
	if use x86-fbsd; then
		insinto /boot/modules
		doins "${S}/src/nvidia.kld"
	fi

	exeinto /boot/modules
	doexe "${S}/src/nvidia.ko"
}

pkg_preinst() {
	use kernel_linux && pkg_preinst_linux
}

pkg_preinst_linux() {
	linux-mod_pkg_preinst

	local videogroup="$(egetent group video | cut -d ':' -f 3)"
	if [ -z "${videogroup}" ]; then
		eerror "Failed to determine the video group gid"
		die "Failed to determine the video group gid"
	else
		sed -i \
			-e "s:PACKAGE:${PF}:g" \
			-e "s:VIDEOGID:${videogroup}:" \
			"${D}"/etc/modprobe.d/nvidia.conf || die
	fi
}

pkg_postinst() {
	use kernel_linux && linux-mod_pkg_postinst
}
