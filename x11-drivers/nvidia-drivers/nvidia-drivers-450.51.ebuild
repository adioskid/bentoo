# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit eutils flag-o-matic linux-info linux-mod multilib-minimal nvidia-driver \
	portability toolchain-funcs unpacker user udev

DESCRIPTION="NVIDIA Accelerated Graphics Driver"
HOMEPAGE="http://www.nvidia.com/ http://www.nvidia.com/Download/Find.aspx"

AMD64_FBSD_NV_PACKAGE="NVIDIA-FreeBSD-x86_64-${PV}"
AMD64_NV_PACKAGE="NVIDIA-Linux-x86_64-${PV}"
ARM_NV_PACKAGE="NVIDIA-Linux-armv7l-gnueabihf-${PV}"
X86_FBSD_NV_PACKAGE="NVIDIA-FreeBSD-x86-${PV}"
X86_NV_PACKAGE="NVIDIA-Linux-x86-${PV}"

NV_URI="http://download.nvidia.com/XFree86/"

SRC_URI="
	amd64? ( ${NV_URI}Linux-x86_64/${PV}/${AMD64_NV_PACKAGE}-no-compat32.run )
	amd64-fbsd? ( ${NV_URI}FreeBSD-x86_64/${PV}/${AMD64_FBSD_NV_PACKAGE}.tar.gz )
"

if [ ${PV%%.*} -le 390 ] ; then
	SRC_URI="${SRC_URI}
		x86? ( ${NV_URI}Linux-x86/${PV}/${X86_NV_PACKAGE}.run )
		x86-fbsd? ( ${NV_URI}FreeBSD-x86/${PV}/${X86_FBSD_NV_PACKAGE}.tar.gz )
		arm? ( ${NV_URI}Linux-32bit-ARM/${PV}/${ARM_NV_PACKAGE}.run )
	"
fi

LICENSE="GPL-2 NVIDIA-r2"
SLOT="0/${PV%.*}"
KEYWORDS="-* ~amd64 ~amd64-fbsd"
RESTRICT="bindist strip"
EMULTILIB_PKG="true"

IUSE="+X +opencl +cuda tools"
IUSE_KERNELS="kernel_FreeBSD kernel_linux"
IUSE_NV_PKG="+opengl +gpgpu +nvpd +nvifr +nvfbc +nvcuvid +nvml +encodeapi +vdpau +xutils +xdriver"

if [ ${PV%%.*} -ge 384 ] ; then IUSE_NV_PKG="${IUSE_NV_PKG} +egl" ; IUSE="${IUSE} +glvnd +uvm +wayland" ; else IUSE="${IUSE} uvm" ; fi
if [ ${PV%%.*} -ge 400 ] ; then IUSE_NV_PKG="${IUSE_NV_PKG} +optix +raytracing" ; fi
if [ ${PV%%.*} -ge 418 ] ; then IUSE_NV_PKG="${IUSE_NV_PKG} +opticalflow" ; fi

IUSE_DUMMY="static-libs acpi"

IUSE="${IUSE} ${IUSE_KERNELS} ${IUSE_NV_PKG} ${IUSE_DUMMY}"


COMMON="
	opencl? (
		app-eselect/eselect-opencl
		dev-libs/ocl-icd
	)
	kernel_linux? ( >=sys-libs/glibc-2.6.1 )
	X? ( app-misc/pax-utils )
"

# glvnd, egl, and wayland support begand in 384.x
if [ ${PV%%.*} -ge 384 ] ; then
	COMMON="${COMMON}
		X? (
			!glvnd? ( >=app-eselect/eselect-opengl-1.0.9 )
			glvnd? ( >=media-libs/libglvnd-1.0.0.20180424 )
		)
	"
	RDEPEND="wayland? ( dev-libs/wayland )"
fi

DEPEND="
	${COMMON}
	kernel_linux? ( virtual/linux-sources )
"

RDEPEND="
	${COMMON}
	${RDEPEND}
	acpi? ( sys-power/acpid )
	X? (
		>=x11-base/xorg-server-1.20.8
		>=x11-libs/libX11-1.6.2
		>=x11-libs/libXext-1.3.2
		>=x11-libs/libvdpau-1.0
		sys-libs/zlib
		x11-libs/gtk+:3
	)
"

S="${WORKDIR}/"

NV_ROOT="${EPREFIX}/opt/nvidia/${P}"
NV_DISTFILES_PATH="${NV_ROOT}/distfiles/"
NV_NATIVE_LIBDIR="${NV_ROOT%/}/lib64"
NV_COMPAT32_LIBDIR="${NV_ROOT%/}/lib32"

QA_PREBUILT="${NV_ROOT#${EPREFIX}/}/*"

# Relative to $NV_ROOT
NV_BINDIR="bin"
NV_INCDIR="include"
NV_SHAREDIR="share"

# Relative to $NV_ROOT/lib{32,64}
NV_LIBDIR="/"
NV_OPENGL_VEND_DIR="opengl/nvidia"
NV_OPENCL_VEND_DIR="OpenCL/nvidia"
NV_X_MODDIR="xorg/modules"

# Maximum supported kernel version in form major.minor
: "${NV_MAX_KERNEL_VERSION:=5.7}"

# Fixups for issues with particular versions of the package.
nv_do_fixups() {

	use_if_iuse wayland \
		&& [ "${D}${NV_NATIVE_LIBDIR}/libnvidia-egl-wayland.so.1".* != "${D}${NV_NATIVE_LIBDIR}/libnvidia-egl-wayland.so.1.*" ] \
		&& ! [ -h "${NV_NATIVE_LIBDIR}/libnvidia-egl-wayland.so.1" ] \
		&& dosym "$(cd "${D}${NV_NATIVE_LIBDIR}" && ls -1 libnvidia-egl-wayland.so.1.* | tail -1)" "${NV_NATIVE_LIBDIR}/libnvidia-egl-wayland.so.1"
}

# Check if we should use a given nvidia MODULE:<arg>
# Convert module names to use-flags as appropriate
nv_use() {
	local mymodule
	mymodule="${1}"
	case "${mymodule}" in
		installer) mymodule="" ;;
		compiler|gpgpucomp) mymodule="gpgpu" ;;
	esac

	[ -z "${mymodule}" ] || use_if_iuse "${mymodule}" || return 1
	return 0
}

# Determine whether we should install GLVND, NON_GLVND, or neither version.
_nv_glvnd() {
	case "$1" in
		GLVND) use_if_iuse glvnd && return 1 ;; # We want to use the system libglvnd, so skip installing from packaging.
		NON_GLVND) ! use_if_iuse glvnd && return 0 ;;
	esac
	return 1
}

# Check tls type
_nv_tls() {
	# Always install both.
	case "$1" in
		CLASSIC|NEW) return 0 ;;
	esac
	return 1
}

# <dir> <file> <perms> <MODULE:>
nv_install() {
	local mydir="${1#${NV_ROOT}}"
	mydir="${NV_ROOT}/${mydir#/}"
	local myfile="${2#/}"
	local myperms="$3"
	local mymodule="${4#MODULE:}"

	nv_use "${mymodule}" || return 0
	einfo "[${mymodule:-*}] Installing '${myfile}' with perms ${myperms} to '${mydir%/}'."

	if ! [ -e "${myfile}" ] ; then
		ewarn "File '${myfile}' specified in manifest does not exist!"
		return 1
	fi

	insinto "${mydir%/}"
	insopts "-m${myperms}"
	doins "${myfile}"
}

# <dir> <file> <perms> <arch> <MODULE:>
nv_install_lib_arch() {
	local libdir
	case "${4}" in
		NATIVE) libdir="${NV_NATIVE_LIBDIR}" ;;
		*) die "nv_install_lib_arch called with something other than NATIVE or COMPAT32 arch" ;;
	esac
	nv_install "${libdir}/${1#/}" "$2" "$3" "$5"
}

# <dir> <target> <source> <MODULE:>
nv_symlink() {
	local mydir="${1#${NV_ROOT}}"
	mydir="${NV_ROOT}/${mydir#/}"
	local mytgt="${2#/}"
	local mysrc="$3"
	local mymodule="${4#MODULE:}"
	nv_use "${mymodule}" || return 0
	einfo "[${mymodule:-*}] Linking '${mysrc}' to '${mytgt}' in '${mydir%/}'."
	dosym "${mysrc}" "${mydir%/}/${mytgt#/}"
}

# <dir> <target> <arch> <source> <MODULE:>
nv_symlink_lib_arch() {
	local libdir
	case "${3}" in
		NATIVE) libdir="${NV_NATIVE_LIBDIR}" ;;
		*) die "nv_install_lib_arch called with something other than NATIVE or COMPAT32 arch" ;;
	esac
	nv_symlink "${libdir%/}/${1#/}" "$2" "$4" "$5"
}

# <dir> <name> <perms> <MODULE:>
nv_install_modprobe() {
	nv_use "${4#MODULE:}" || return 0
	# install nvidia-modprobe setuid and symlink in /usr/bin (bug #505092)
	nv_install "${1}" "${2}" "${3}" "${4}"
	fowners root:video "${NV_ROOT}/${1%/}/nvidia-modprobe"
	fperms 4710 "${NV_ROOT}/${1%/}/nvidia-modprobe"
}

# <dir> <template> <perms> <MODULE:>
nv_install_vulkan_icd() {
	nv_use "${4#MODULE:}" || return 0
	if [ -e nvidia_icd.json.template ]; then
		rm -f "nvidia_icd.json" || die
		sed -e 's:__NV_VK_ICD__:'"${NV_NATIVE_LIBDIR}"'/libGLX_nvidia.so.0:g' nvidia_icd.json.template > nvidia_icd.json || die
	fi
	nv_install "$1" "nvidia_icd.json" "$3" "$4"
}

# <dir> <file> <perms> <MODULE:>
nv_install_outputclass_config() {
	nv_use "${4#MODULE:}" || return 0
	nv_install "${1}" "${2}" "${3}" "${4}"
	sed -e '/EndSection/ i\\tModulePath "'"${NV_NATIVE_LIBDIR}"'"\n\tModulePath "'"${NV_NATIVE_LIBDIR}/${NV_X_MODDIR}"'"\n\tModulePath "'"${NV_NATIVE_LIBDIR}/${NV_OPENGL_VEND_DIR}/extensions"'"' \
		-i "${D%/}/${NV_ROOT#/}/${1#/}/${2#/}"
}

# <dir> <file> <perms> <MODULE:>
nv_install_desktop() {
	nv_use "${4#MODULE:}" || return 0
	nv_install "${1%/*}" "${2}" "${3}" "${4}"
	sed -e 's|__UTILS_PATH__|'"${NV_ROOT}/bin"'|' \
		-e 's|__PIXMAP_PATH__|'"${NV_ROOT}/${1/applications/doc}"'|' \
		-i "${D}${NV_ROOT}/${1%/*}/${2#/}"
}

# Run from root of extracted nvidia-drivers package.
nv_parse_manifest() {
	[ -r .manifest ] || die "Can not read .manifest!"
	local name perms type f4 f5 f6 f7
	local module fields
	while read -r name perms type f4 f5 f6 f7; do
		#einfo "Manifest entry: '$name' '$perms' '$type' '$f4' '$f5' '$f6' '$f7'"

		# Figure out which is our last field, and if it contains a MODULE: entry, grab that value and clear the field.
		case "${f7}~${f6}~${f5}~${f4}~" in
			MODULE:*~*~*~*~) module="$f7" ; f7="" ; fields=6 ;;
			~MODULE:*~*~*~) module="$f6" ; f6="" ; fields=5 ;;
			~~MODULE:*~*~) module="$f5" ; f5="" ; fields=4 ;;
			~~~MODULE:*~) module="$f4" ; f4="" ; fields=3 ;;
			~*~*~*~) fields=6 ;;
			~~*~*~) fields=5 ;;
			~~~*~) fields=4 ;;
			~~~~) fields=3 ;;
		esac

		case "$type" in

			#<libname> <perms> <type> <NATIVE/COMPAT32> MODULE:<module>
			#<libname> <perms> OPENGL_LIB <NATIVE/COMPAT32> MODULE:<module>
			#<libname> <perms> LIBGL_LA <NATIVE/COMPAT32> MODULE:<module>
			#<libname> <perms> GLVND_LIB <NATIVE/COMPAT32> MODULE:<module>
			#<libname> <perms> NVCUVID_LIB <NATIVE/COMPAT32> MODULE:<module>
			#<libname> <perms> ENCODEAPI_LIB <NATIVE/COMPAT32> MODULE:<module>
			#<libname> <perms> NVIFR_LIB <NATIVE/COMPAT32> MODULE:<module>
			#<libname> <perms> UTILITY_LIB <NATIVE/COMPAT32> MODULE:<module>
			GLVND_LIB) _nv_glvnd "GLVND" && nv_install_lib_arch "${NV_OPENGL_VEND_DIR}/lib/${f5%/}" "$name" "$perms" "$f4" "$module" ;;
			OPENGL_LIB|LIBGL_LA|NVCUVID_LIB|ENCODEAPI_LIB|NVIFR_LIB|UTILITY_LIB) nv_install_lib_arch "${NV_LIBDIR}/${f5%/}" "$name" "$perms" "$f4" "$module" ;;

			#<libname> <perms> <type> <NATIVE/COMPAT32> <subdir> MODULE:<module>
			#<libname> <perms> CUDA_LIB <NATIVE/COMPAT32> <subdir> MODULE:<module>
			#<libname> <perms> OPENCL_LIB <NATIVE/COMPAT32> <subdir> MODULE:<module>
			#<libname> <perms> OPENCL_WRAPPER_LIB <NATIVE/COMPAT32> <subdir> MODULE:<module>
			#<libname> <perms> VDPAU_LIB <NATIVE/COMPAT32> <subdir> MODULE:<module>
			OPENCL_LIB|CUDA_LIB|VDPAU_LIB|VDPAU_WRAPPER_LIB) nv_install_lib_arch "${NV_LIBDIR}/${f5%/}" "$name" "$perms" "$f4" "$module" ;;
			OPENCL_WRAPPER_LIB) nv_install_lib_arch "${NV_OPENCL_VEND_DIR}/lib/${f5%/}" "$name" "$perms" "$f4" "$module" ;;

			#<libname> <perms> <type> <NATIVE/COMPAT32> <GLVND/NON_GLVND> MODULE:<module>
			#<libname> <perms> GLX_CLIENT_LIB <NATIVE/COMPAT32> <GLVND/NON_GLVND> MODULE:<module>
			#<libname> <perms> EGL_CLIENT_LIB <NATIVE/COMPAT32> <GLVND/NON_GLVND> MODULE:<module>
			GLX_CLIENT_LIB|EGL_CLIENT_LIB) _nv_glvnd "$f5" && nv_install_lib_arch "${NV_OPENGL_VEND_DIR}/lib" "$name" "$perms" "$f4" "$module" ;;


			#<libname> <perms> <type> <NATIVE/COMPAT32> [<CLASSIC/NEW>] <subdir> MODULE:<module>
			#<libname> <perms> TLS_LIB <NATIVE/COMPAT32> <CLASSIC/NEW> <subdir> MODULE:<module>
			#<libname> <perms> TLS_LIB <NATIVE/COMPAT32> <subdir> MODULE:<module>
			TLS_LIB)
				case "$f5" in
					CLASSIC|NEW) _nv_tls "$f5" && nv_install_lib_arch "${NV_LIBDIR}/${f6%/}" "$name" "$perms" "$f4" "$module" ;;
					*) nv_install_lib_arch "${NV_LIBDIR}/${f5%/}" "$name" "$perms" "$f4" "$module" ;;
				esac;;

			#<libname-tgt> <perms> <type> <NATIVE/COMPAT32> <libname-src> MODULE:<module>
			#<libname-tgt> <perms> OPENGL_SYMLINK <NATIVE/COMPAT32> <libname-src> MODULE:<module>
			#<libname-tgt> <perms> GLVND_SYMLINK <NATIVE/COMPAT32> <libname-src> MODULE:<module>
			#<libname-tgt> <perms> NVCUVID_LIB_SYMLINK <NATIVE/COMPAT32> <libname-src> MODULE:<module>
			#<libname-tgt> <perms> ENCODEAPI_LIB_SYMLINK <NATIVE/COMPAT32> <libname-src> MODULE:<module>
			#<libname-tgt> <perms> NVIFR_LIB_SYMLINK <NATIVE/COMPAT32> <libname-src> MODULE:<module>
			#<libname-tgt> <perms> UTILITY_LIB_SYMLINK <NATIVE/COMPAT32> <libname-src> MODULE:<module>
			GLVND_SYMLINK)_nv_glvnd "GLVND" && nv_symlink_lib_arch "${NV_OPENGL_VEND_DIR}/lib" "$name" "$f4" "$f5" "$module" ;;
			OPENGL_SYMLINK|NVCUVID_LIB_SYMLINK|ENCODEAPI_LIB_SYMLINK|NVIFR_LIB_SYMLINK|UTILITY_LIB_SYMLINK) nv_symlink_lib_arch "${NV_LIBDIR}" "$name" "$f4" "$f5" "$module" ;;

			#<libname-tgt> <perms> <type> <NATIVE/COMPAT32> <subdir> <libname-src> MODULE:<module>
			#<libname-tgt> <perms> CUDA_SYMLINK <NATIVE/COMPAT32> <subdir> <libname-src> MODULE:<module>
			#<libname-tgt> <perms> OPENCL_LIB_SYMLINK <NATIVE/COMPAT32> <subdir> <libname-src> MODULE:<module>
			#<libname-tgt> <perms> OPENCL_WRAPPER_SYMLINK <NATIVE/COMPAT32> <subdir> <libname-src> MODULE:<module>
			#<libname-tgt> <perms> VDPAU_SYMLINK <NATIVE/COMPAT32> <subdir> <libname-src> MODULE:<module>
			OPENCL_LIB_SYMLINK|CUDA_SYMLINK|VDPAU_SYMLINK|VDPAU_WRAPPER_SYMLINK) nv_symlink_lib_arch "${NV_LIBDIR}/${f5%/}" "$name" "$f4" "$f6" "$module" ;;
			OPENCL_WRAPPER_SYMLINK) nv_symlink_lib_arch "${NV_OPENCL_VEND_DIR}/lib/${f5%/}" "$name" "$f4" "$f6" "$module" ;;

			#<libname-tgt> <perms> <type> <NATIVE/COMPAT32> <libname-src> <GLVND/NON_GLVND> MODULE:<module>
			#<libname-tgt> <perms> GLX_CLIENT_SYMLINK <NATIVE/COMPAT32> <libname-src> <GLVND/NON_GLVND> MODULE:<module>
			#<libname-tgt> <perms> EGL_CLIENT_SYMLINK <NATIVE/COMPAT32> <libname-src> <GLVND/NON_GLVND> MODULE:<module>
			GLX_CLIENT_SYMLINK|EGL_CLIENT_SYMLINK) _nv_glvnd "$f6" && nv_symlink_lib_arch "${NV_OPENGL_VEND_DIR}/lib" "$name" "$f4" "$f5" "$module" ;;

			#<libname> <perms> <type> <subdir> MODULE:<module>
			#<libname> <perms> X_MODULE_SHARED_LIB <subdir> MODULE:<module>
			#<libname> <perms> GLX_MODULE_SHARED_LIB <subdir> MODULE:<module>
			XMODULE_SHARED_LIB) nv_install "$(get_libdir)/${NV_X_MODDIR}/${f4%/}" "$name" "$perms" "$module";;
			GLX_MODULE_SHARED_LIB) nv_install "$(get_libdir)/${NV_OPENGL_VEND_DIR}/${f4%/}" "$name" "$perms" "$module" ;;

			#<libname-tgt> <perms> <type> <subdir> <libname-src> MODULE:<module>
			#<libname-tgt> <perms> XMODULE_SYMLINK <subdir> <libname-src> MODULE:<module>
			#<libname-tgt> <perms> XMODULE_NEWSYM <subdir> <libname-src> MODULE:<module>
			#<libname-tgt> <perms> GLX_MODULE_SYMLINK <subdir> <libname-src> MODULE:<module>
			XMODULE_SYMLINK|XMODULE_NEWSYM) nv_symlink "$(get_libdir)/${NV_X_MODDIR}/${f4%/}" "$name" "$f5" "$module";;
			GLX_MODULE_SYMLINK) nv_symlink "$(get_libdir)/${NV_OPENGL_VEND_DIR}/${f4%/}" "$name" "$f5" "$module" ;;

			#<file> <perms> <type> <subdir> MODULE:<module>
			#<header> <perms> OPENGL_HEADER <subdir> MODULE:<module>
			#<profile> <perms> APPLICATION_PROFILE <subdir> MODULE:<module>
			#<file> <perms> DOCUMENTATION <subdir> MODULE:<module>
			#<file> <perms> DOT_DESKTOP <subdir> MODULE:<module>
			#<file> <perms> MANPAGE <subdir> MODULE:<module>
			#<binary> <perms> NVIDIA_MODPROBE <subdir> MODULE:<module>
			#<file> <perms> NVIDIA_MODPROBE_MANPAGE <subdir> MODULE:<module>
			#<file> <perms> EXPLICIT_PATH <subdir> MODULE:<module>  (used in 340.x)
			OPENGL_HEADER) nv_install "${NV_INCDIR}/${f4%/}" "$name" "$perms" "$module" ;;
			APPLICATION_PROFILE) nv_install "${NV_SHAREDIR}/nvidia/${f4%/}" "$name" "$perms" "$module" ;;
			DOT_DESKTOP) nv_install_desktop "${NV_SHAREDIR}/applications/${f4%/}" "$name" "$perms" "$module" ;;
			NVIDIA_MODPROBE) nv_install_modprobe "${NV_BINDIR}" "$name" "$perms" "$module" ;;
			NVIDIA_MODPROBE_MANPAGE|MANPAGE) nv_install "${NV_SHAREDIR}/man/${f4%/}" "$name" "$perms" "$module" ;;
			DOCUMENTATION) nv_install "${NV_SHAREDIR}/doc/${f4%/}" "$name" "$perms" "$module" ;;
			EXPLICIT_PATH) nv_install "${ED%/}/${f4%/}" "$name" "$perms" "$module" ;;

			#<file> <perms> <type> MODULE:<module>
			#<binary> <perms> INSTALLER_BINARY MODULE:<module>
			#<binary> <perms> UTILITY_BINARY MODULE:<module>
			#<conf-file> <perms> XORG_OUTPUTCLASS_CONFIG MODULE:<module>
			#<file> <perms> CUDA_ICD MODULE:<module>
			#<file> <perms> VULKAN_ICD_JSON MODULE:<module>
			#<file> <perms> GLVND_EGL_ICD_JSON MODULE:<module>
			#<file> <perms> EGL_EXTERNAL_PLATFORM_JSON MODULE:<module>
			INSTALLER_BINARY) [ "x${name}" = "xnvidia-installer" ] || nv_install "${NV_BINDIR}" "$name" "$perms" "$module" ;;
			UTILITY_BINARY) nv_install "${NV_BINDIR}" "$name" "$perms" "$module" ;;
			XORG_OUTPUTCLASS_CONFIG) nv_install_outputclass_config "${NV_SHAREDIR}/X11/xorg.conf.d" "$name" "$perms" "$module" ;;
			CUDA_ICD) nv_install "${NV_SHAREDIR}/OpenCL/vendors/" "$name" "$perms" "$module" ;;
			VULKAN_ICD_JSON) nv_install_vulkan_icd "${NV_SHAREDIR}/vulkan/icd.d/" "$name" "$perms" "$module" ;;
			GLVND_EGL_ICD_JSON) nv_install "${NV_SHAREDIR}/glvnd/egl_vendor.d/" "$name" "$perms" "$module" ;;
			EGL_EXTERNAL_PLATFORM_JSON) nv_install "${NV_SHAREDIR}/egl/egl_external_platform.d/" "$name" "$perms" "$module" ;;

			#<bin-tgt> <perms> <type> <bin-src> MODULE:<module>
			#<bin-tgt> <perms> UTILITY_BIN_SYMLINK <bin-src> MODULE:<module>
			UTILITY_BIN_SYMLINK) [ "x${f4}" = "xnvidia-installer" ] || nv_symlink "${NV_BINDIR}" "$name" "$f4" "$module" ;;

			# Kernel modules sources handled elsewhere
			KERNEL_MODULE_SRC|UVM_MODULE_SRC|DKMS_CONF) : ;;
			UVM_MODULE_SRC) : ;;



			# Warn about any unhandled manifest entries
			*) ewarn "Unhandled manifest entry: ${name} ${perms} ${type} ${f4} ${f5} ${f6} ${f7}" ;;
		esac
		
	done <<-EOF
		$(tail -n +9 .manifest)
	EOF
}

nvidia_drivers_versions_check() {
	if use_if_iuse amd64 && has_multilib_profile && \
		[ "${DEFAULT_ABI}" != "amd64" ]; then
		eerror "This ebuild doesn't currently support changing your default ABI"
		die "Unexpected \${DEFAULT_ABI} = ${DEFAULT_ABI}"
	fi

	if use kernel_linux && kernel_is ge ${NV_MAX_KERNEL_VERSION%%.*} ${NV_MAX_KERNEL_VERSION#*.}; then
		ewarn "These NVIDIA drivers are designed to work with Linux ${NV_MAX_KERNEL_VERSION} or earlier."
	fi

	# Since Nvidia ships many different series of drivers, we need to give the user
	# some kind of guidance as to what version they should install. This tries
	# to point the user in the right direction but can't be perfect. check
	# nvidia-driver.eclass
	nvidia-driver-check-warning

	# Kernel features/options to check for
	CONFIG_CHECK="~ZONE_DMA ~MTRR ~SYSVIPC ~!LOCKDEP"
	use_if_iuse x86 && CONFIG_CHECK+=" ~HIGHMEM"
	use cuda && CONFIG_CHECK+=" ~NUMA ~CPUSETS"

	# Now do the above checks
	use kernel_linux && check_extra_config
}

pkg_pretend() {
	nvidia_drivers_versions_check
}

pkg_setup() {
	nvidia_drivers_versions_check

	# set variables to where files are in the package structure
	if use kernel_FreeBSD; then
		NV_KMOD_SRC="${S}/src"
	elif use kernel_linux; then
		NV_KMOD_SRC="${S}/kernel"
	else
		die "Could not determine proper NVIDIA kernel modules' source path in package."
	fi
}

src_unpack() {
	if [ -z "${SRC_URI}" ] ; then
		if [ -d "${NV_DISTFILES_PATH}" ] ; then
			use_if_iuse amd64 && NV_PACKAGE="${AMD64_NV_PACKAGE}"
			use_if_iuse amd64-fbsd && NV_PACKAGE="${AMD64_FBSD_NV_PACKAGE}"
			use_if_iuse arm64 && NV_PACKAGE="${ARM64_NV_PACKAGE}"
			use_if_iuse x86 && NV_PACKAGE="${X86_NV_PACKAGE}"
			use_if_iuse x86-fbsd && NV_PACKAGE="${X86_FBSD_NV_PACKAGE}"
			use_if_iuse arm && NV_PACKAGE="${ARM_NV_PACKAGE}"
			if [ -f "${NV_DISTFILES_PATH}/${NV_PACKAGE}.run" ] ; then
				unpacker "${NV_DISTFILES_PATH}/${NV_PACKAGE}.run"
			else
				die "No '${NV_PACKAGE}.run' exists in '${NV_DISTFILES_PATH}'."
			fi
		else
			die "No SRC_URI given and no '${NV_DISTFILES_PATH}' directory exists."
		fi
	else
		unpacker
	fi
}

src_prepare() {
	# Reclassify wayland-related files to MODULE:wayland
	sed -e 's:\(wayland.*\)egl:\1wayland:g' -i .manifest
	default
}

src_install() {

	# Parse our manifest file and install to our destroot.
	nv_parse_manifest

	# Remove symlink libwfb.so if it exists to avoid problems. (per nvidia docs)
	rm -f "${D}${NV_ROOT}/$(get_libdir)/${NV_X_MODDIR}/libwfb.so"

	# Install source for kernel modules
	dodir "${NV_ROOT}/src/kernel-modules"
	(set +f; cp -r "${NV_KMOD_SRC}"/* "${D}${NV_ROOT}/src/kernel-modules" || return 1 ) || die "Could not copy kernel module sources!"

	# Link nvidia-modprobe utility to /usr/bin if installed.
	[ -f "${D}${NV_ROOT}/bin/nvidia-modprobe" ] && dosym "${NV_ROOT}/bin/nvidia-modprobe" "/usr/bin/nvidia-modprobe"

	# If 'tools' flag is enabled, link nvidia-settings utility into /usr/bin, install an xinitrc.d file to start it, and link it's desktop file.
	if use tools; then
		for tool in settings xconfig; do
			[ -f "${D}${NV_ROOT}/bin/nvidia-${tool}" ] && dosym "${NV_ROOT}/bin/nvidia-${tool}" "/usr/bin/nvidia-${tool}"
		done
		exeinto /etc/X11/xinit/xinitrc.d
		newexe "${FILESDIR}"/95-nvidia-settings.xinitrc 95-nvidia-settings
		dosym "${NV_ROOT}/share/applications/nvidia-settings.desktop" "/usr/share/applications/nvidia-settings.desktop"
		dosym "${NV_ROOT}/share/nvidia" "/usr/share/nvidia"
	fi

	# If 'X' flag is enabled, link nvidia-drm-outputclass.conf into system xorg.conf.d directory (xorg 1.16 and up),
	# link nvidia_drv.so into /usr/$(get_libdir)/xorg/modules/drivers,
	# and link nvidia_icd.json into system vulkan/icd.d directory.
	if use X; then

		# Xorg nvidia.conf
		if has_version '>=x11-base/xorg-server-1.16'; then
			dosym "${NV_ROOT}/share/X11/xorg.conf.d/nvidia-drm-outputclass.conf" "/usr/share/X11/xorg.conf.d/50-nvidia-drm-outputclass.conf"
		fi

		# Xorg driver nvidia_drv.so
		dosym "${NV_NATIVE_LIBDIR}/xorg/modules/drivers/nvidia_drv.so" "/usr/$(get_libdir)/xorg/modules/drivers/nvidia_drv.so"

		# Vulkan ICD
		dosym "${NV_ROOT}/share/vulkan/icd.d/nvidia_icd.json" "/etc/vulkan/icd.d/nvidia_icd.json"
	fi

	# If 'egl' flag is enabled, link 10_nvidia.json into the system egl_vendor.d directory.
	use_if_iuse egl && dosym "${NV_ROOT}/share/glvnd/egl_vendor.d/10_nvidia.json" "/usr/share/glvnd/egl_vendor.d/10_nvidia.json"

	# If 'egl' flag is enabled, link 10_nvidia_wayland.json into the system egl_external_platform.d directory.
	use_if_iuse wayland && dosym "${NV_ROOT}/share/egl/egl_external_platform.d/10_nvidia_wayland.json" "/usr/share/egl/egl_external_platform.d/10_nvidia_wayland.json"

	# OpenCL ICD for NVIDIA
	# If 'opencl' or 'cuda' flags are enabled, link nvdidia.icd into system OpenCL/vendors directory.
	( use opencl || use cuda ) && dosym "${NV_ROOT}/share/OpenCL/vendors/nvidia.icd" "/etc/OpenCL/vendors/nvidia.icd"

	# On linux kernels, install nvidia-persistenced init and conf files after fixing up paths.
	if use_if_iuse kernel_linux; then
		for filename in nvidia-{smi,persistenced}.init ; do
			sed -e 's:/opt/bin:'"${NV_ROOT}"'/bin:g' "${FILESDIR}/${filename}" > "${T}/${filename}"
			newinitd "${T}/${filename}" "${filename%.init}"
		done
		newconfd "${FILESDIR}/nvidia-persistenced.conf" nvidia-persistenced
	fi

	# If we're not using glvnd support, then set up directory expected by eselect opengl: 
	if ! use_if_iuse glvnd ; then
		dosym "${NV_NATIVE_LIBDIR}/opengl/nvidia" "${EPREFIX}/usr/lib/opengl/nvidia"
	fi

	# Support link for Bumblebee
	dosym "${NV_NATIVE_LIBDIR}" "${EPREFIX}/usr/lib/nvidia"

	readme.gentoo_create_doc

	# Setup an env.d file with appropriate lib paths.
	ldpath="${NV_NATIVE_LIBDIR}:${NV_NATIVE_LIBDIR}/tls"
	printf -- "LDPATH=\"${ldpath}\"\n" > "${T}/09nvidia"
	doenvd "${T}/09nvidia"

	# Run fixups specific to this driver (defined at top)
	nv_do_fixups

	for x in ${D}/${NV_ROOT}/share/man/man1/*; do
		gzip -d $x
		doman ${x%.gz}
	done
	rm -rf ${D}/${NV_ROOT}/share/man || die

}


pkg_preinst() {

	# Clean the dynamic libGL stuff's home to ensure
	# we dont have stale libs floating around
	if [ -d "${ROOT}"/usr/lib/opengl/nvidia ]; then
		rm -rf "${ROOT}"/usr/lib/opengl/nvidia
	fi
	# Make sure we nuke the old nvidia-glx's env.d file
	if [ -e "${ROOT}"/etc/env.d/09nvidia ]; then
		rm -f "${ROOT}"/etc/env.d/09nvidia
	fi
}

pkg_postinst() {

	# If we'e not using glvnd, switch to the nvidia opengl vendor implementation
	! use_if_iuse glvnd && use X && "${ROOT}"/usr/bin/eselect opengl set --use-old nvidia
	use opencl && "${ROOT}"/usr/bin/eselect opencl set --use-old ocl-icd

	readme.gentoo_print_elog

	if ! use X; then
		elog "You have elected to not install the X.org driver. Along with"
		elog "this the OpenGL libraries and VDPAU libraries were not"
		elog "installed. Additionally, once the driver is loaded your card"
		elog "and fan will run at max speed which may not be desirable."
		elog "Use the 'nvidia-smi' init script to have your card and fan"
		elog "speed scale appropriately."
		elog
	fi
}

pkg_prerm() {
	! use_if_iuse glvnd && use X && "${ROOT}"/usr/bin/eselect opengl set --use-old xorg-x11
}

pkg_postrm() {
	! use_if_iuse glvnd && use X && "${ROOT}"/usr/bin/eselect opengl set --use-old xorg-x11
}
