# Distributed under the terms of the GNU General Public License v2

# See README.txt for usage notes.

EAPI=7

inherit multilib-build eutils pax-utils toolchain-enable git-r3

RESTRICT="strip"
FEATURES=${FEATURES/multilib-strict/}

GCC_MAJOR="${PV%%.*}"

IUSE="ada +cxx d go +fortran objc objc++ objc-gc " # Languages
IUSE="$IUSE test" # Run tests
IUSE="$IUSE doc nls vanilla multilib" # docs/i18n/system flags
IUSE="$IUSE openmp altivec graphite pch generic_host" # Optimizations/features flags
IUSE="$IUSE +bootstrap bootstrap-lean bootstrap-profiled bootstrap-lto bootstrap-O3" # Bootstrap flags
IUSE="$IUSE libssp +ssp" # Base hardening flags
IUSE="$IUSE +pie +vtv link_now ssp_all" # Extra hardening flags
[ ${GCC_MAJOR} -ge 8 ] && IUSE="$IUSE +stack_clash_protection" # Stack clash protector added in gcc-8
IUSE="$IUSE sanitize dev_extra_warnings" # Dev flags

# Handle internal self checking options
CHECKS_RELEASE="assert runtime"
CHECKS_YES="${CHECKS_RELEASE} misc tree gc rtlflag"
CHECKS_EXTRA="$( [ ${GCC_MAJOR} -ge 8 ] && printf -- "extra" )"
CHECKS_VALGRIND="valgrind"
CHECKS_ALL="${CHECKS_YES} df fold gcac rtl ${CHECKS_EXTRA}"

for _check in no release yes all ${CHECKS_ALL} ${CHECKS_VALGRIND}; do
	IUSE="${IUSE} checking_${_check} stage1_checking_${_check}"
done


SLOT="${PV}"

# Version of archive before patches.
GCC_ARCHIVE_VER="${PV}"

# GCC release archive
GCC_A="gcc-${GCC_ARCHIVE_VER}.tar.xz"
#SRC_URI="mirror://gnu/gcc/${GCC_ARCHIVE_VER}/${GCC_A}"
SRC_URI="ftp://gcc.gnu.org/pub/gcc/releases/gcc-${GCC_ARCHIVE_VER}/${GCC_A}"

# Backported fixes from gcc svn tree
#GCC_SVN_REV="270849"
if [ -n "$GCC_SVN_REV" ]; then
	GCC_SVN_PATCH_NAME="gcc-${GCC_ARCHIVE_VER}-to-svn-${GCC_SVN_REV}.patch"
	#GCC_SVN_PATCH_URI="https://fastpull-us.funtoo.org/distfiles/${GCC_SVN_PATCH_NAME}"
	if [ -z "${GCC_SVN_PATCH_URI}" ]; then
		GCC_SVN_PATCH_PATH="${FILESDIR}/svn-patches"
	else
		SRC_URI="${SRC_URI} ${GCC_SVN_PATCH_NAME}"
		GCC_SVN_PATCH_PATH="${DISTDIR}"
	fi
	GCC_SVN_PATCH="${GCC_SVN_REV:+${GCC_SVN_PATCH_PATH}/gcc-${GCC_ARCHIVE_VER}-to-svn-${GCC_SVN_REV}.patch}"
fi

# Gentoo patcheset
GENTOO_PATCHES_VER="1.0"
GENTOO_GCC_PATCHES_VER="${GCC_ARCHIVE_VER}"
GENTOO_PATCHES_DIR="${FILESDIR}/gentoo-patches/gcc-${GENTOO_GCC_PATCHES_VER}-patches-${GENTOO_PATCHES_VER}"
GENTOO_PATCHES=(
#	01_all_default-fortify-source.patch
#	02_all_default-warn-format-security.patch
#	03_all_default-warn-trampolines.patch
	04_all_default-ssp-fix.patch
	05_all_alpha-mieee-default.patch
	06_all_ia64_note.GNU-stack.patch
	07_all_i386_libgcc_note.GNU-stack.patch
	08_all_libiberty-asprintf.patch
	09_all_libiberty-pic.patch
	10_all_nopie-all-flags.patch
	11_all_extra-options.patch
	12_all_pr55930-dependency-tracking.patch
	13_all_sh-drop-sysroot-suffix.patch
	14_all_ia64-TEXTREL.patch
	15_all_disable-systemtap-switch.patch
	16_all_m68k-textrel-on-libgcc.patch
	17_all_respect-build-cxxflags.patch
	18_all_libgfortran-Werror.patch
	19_all_libgomp-Werror.patch
	20_all_libitm-Werror.patch
	21_all_libatomic-Werror.patch
	22_all_libbacktrace-Werror.patch
	23_all_libsanitizer-Werror.patch
	24_all_libstdcxx-no-vtv.patch
	25_all_ia64-bootstrap.patch
	26_all_disable-riscv32-ABIs.patch
)

# Math libraries:
GMP_VER="6.2.0"
GMP_EXTRAVER=""
SRC_URI="$SRC_URI mirror://gnu/gmp/gmp-${GMP_VER}${GMP_EXTRAVER}.tar.xz"

MPFR_VER="4.1.0"
MPFR_PATCH_VER=""
SRC_URI="$SRC_URI http://www.mpfr.org/mpfr-${MPFR_VER}/mpfr-${MPFR_VER}.tar.xz"
MPFR_PATCH_FILE="${MPFR_PATCH_VER:+${FILESDIR}/mpfr/mpfr-${MPFR_VER}_to_${MPFR_VER}-p${MPFR_PATCH_VER}.patch}"

MPC_VER="1.2.0"
SRC_URI="$SRC_URI http://ftp.gnu.org/gnu/mpc/mpc-${MPC_VER}.tar.gz"

# Graphite support:
CLOOG_VER="0.18.4"
ISL_VER="0.22"
SRC_URI="$SRC_URI graphite? ( http://www.bastoul.net/cloog/pages/download/count.php3?url=./cloog-${CLOOG_VER}.tar.gz http://isl.gforge.inria.fr/isl-${ISL_VER}.tar.xz )"

# Ada Support:
GNAT32="gnat-gpl-2014-x86-linux-bin.tar.gz"
GNAT64="gnat-gpl-2017-x86_64-linux-bin.tar.gz"
SRC_URI="$SRC_URI ada? ( amd64? ( mirror://funtoo/gcc/${GNAT64} ) x86? ( mirror://funtoo/gcc/${GNAT32} ) )"

# D support
#DLANG_REPO_URI="https://github.com/D-Programming-GDC/GDC.git"
#DLANG_BRANCH="gdc-${GCC_MAJOR}-stable"
#DLANG_COMMIT_DATE="2018-08-26"
#DLANG_CHECKOUT_DIR="${WORKDIR}/gdc"

DESCRIPTION="The GNU Compiler Collection"

LICENSE="GPL-3+ LGPL-3+ || ( GPL-3+ libgcc libstdc++ gcc-runtime-library-exception-3.1 ) FDL-1.3+"
KEYWORDS="*"

RDEPEND="
	sys-libs/zlib[static-libs,${MULTILIB_USEDEP}]
	nls? ( sys-devel/gettext[static-libs,${MULTILIB_USEDEP}] )
	virtual/libiconv[${MULTILIB_USEDEP}]
	objc-gc? ( >=dev-libs/boehm-gc-7.6[static-libs,${MULTILIB_USEDEP}] )
	!sys-devel/gcc:5.3
"
DEPEND="${RDEPEND}
	>=sys-devel/bison-1.875
	>=sys-devel/flex-2.5.4
	>=${CATEGORY}/binutils-2.18
	elibc_glibc? ( >=sys-libs/glibc-2.8 )
	test? ( dev-util/dejagnu sys-devel/autogen )"

PDEPEND="
	>=sys-devel/gcc-config-1.5
	>=sys-devel/libtool-2.4.3
	dev-cpp/tbb
"
# dev-cpp/tbb is required for C++17 support. See FL-6566.

if [[ ${CATEGORY} != cross-* ]] ; then
	PDEPEND="${PDEPEND} elibc_glibc? ( >=sys-libs/glibc-2.8 )"
fi

tc-is-cross-compiler() {
	[[ ${CBUILD:-${CHOST}} != ${CHOST} ]]
}

is_crosscompile() {
	[[ ${CHOST} != ${CTARGET} ]]
}

pkg_setup() {
	# Capture -march -mcpu and -mtune options to pass to build later.
	MARCH="${MARCH:-$(printf -- "${CFLAGS}" | sed -rne 's/.*-march="?([-_[:alnum:]]+).*/\1/p')}"
	MCPU="${MCPU:-$(printf -- "${CFLAGS}" | sed -rne 's/.*-mcpu="?([-_[:alnum:]]+).*/\1/p')}"
	MTUNE="${MTUNE:-$(printf -- "${CFLAGS}" | sed -rne 's/.*-mtune="?([-_[:alnum:]]+).*/\1/p')}"
	MFPU="${MFPU:-$(printf -- "${CFLAGS}" | sed -rne 's/.*-mfpu="?([-_[:alnum:]]+).*/\1/p')}"
	einfo "Got CFLAGS: ${CFLAGS}"
	einfo "Got GCC_BUILD_CFLAGS: ${GCC_BUILD_CFLAGS}"
	einfo "MARCH: ${MARCH}"
	einfo "MCPU ${MCPU}"
	einfo "MTUNE: ${MTUNE}"
	einfo "MFPU: ${MFPU}"

	# Don't pass cflags/ldflags through.
	unset CFLAGS
	unset CXXFLAGS
	unset CPPFLAGS
	unset LDFLAGS
	unset GCC_SPECS # we don't want to use the installed compiler's specs to build gcc!
	unset LANGUAGES #265283
	export PREFIX=/usr
	CTARGET=${CTARGET:-${CHOST}}
	[[ ${CATEGORY} == cross-* ]] && CTARGET=${CATEGORY/cross-}
	GCC_BRANCH_VER=${SLOT}
	GCC_CONFIG_VER=${PV}
	DATAPATH=${PREFIX}/share/gcc-data/${CTARGET}/${GCC_CONFIG_VER}
	if is_crosscompile; then
		BINPATH=${PREFIX}/${CHOST}/${CTARGET}/gcc-bin/${GCC_CONFIG_VER}
	else
		BINPATH=${PREFIX}/${CTARGET}/gcc-bin/${GCC_CONFIG_VER}
	fi

	export CFLAGS="${GCC_BUILD_CFLAGS:--O2 -pipe}"
	export FFLAGS="$CFLAGS"
	export FCFLAGS="$CFLAGS"
	export CXXFLAGS="$CFLAGS"

	LIBPATH=${PREFIX}/lib/gcc/${CTARGET}/${GCC_CONFIG_VER}
	STDCXX_INCDIR=${LIBPATH}/include/g++-v${GCC_BRANCH_VER}

	# Add bootstrap configs to BUILD_CONFIG based on use flags
	if use bootstrap-lto && use bootstrap-lean; then
		BUILD_CONFIG="${BUILD_CONFIG:+${BUILD_CONFIG} }bootstrap-lto-lean"
	elif use bootstrap-lto ; then
		BUILD_CONFIG="${BUILD_CONFIG:+${BUILD_CONFIG} }bootstrap-lto"
	fi
	use bootstrap-O3 && BUILD_CONFIG="${BUILD_CONFIG:+${BUILD_CONFIG} }bootstrap-O3"

	export BUILD_CONFIG

	if [ -n "${GCC_TARGET}" ] ; then
		:
	elif ! is_crosscompile && use bootstrap ; then
		if use bootstrap-profiled ; then
			GCC_TARGET="profiledbootstrap"
		else
			GCC_TARGET="bootstrap"
		fi
		# Handle lean bootstrap target suffix (see Makefile.tpl)
		if use bootstrap-lean ; then
			GCC_TARGET="${GCC_TARGET}-lean"
		fi
	else
		GCC_TARGET="all"
	fi
	export GCC_TARGET


	use doc || export MAKEINFO="/dev/null"
}

src_unpack() {
	unpack $GCC_A
	mv "gcc-${GCC_ARCHIVE_VER}" "${S}"
	( unpack mpc-${MPC_VER}.tar.gz && mv ${WORKDIR}/mpc-${MPC_VER} ${S}/mpc ) || die "mpc setup fail"
	( unpack mpfr-${MPFR_VER}.tar.xz && mv ${WORKDIR}/mpfr-${MPFR_VER} ${S}/mpfr ) || die "mpfr setup fail"
	( unpack gmp-${GMP_VER}${GMP_EXTRAVER}.tar.xz && mv ${WORKDIR}/gmp-${GMP_VER} ${S}/gmp ) || die "gmp setup fail"

	if use graphite; then
		( unpack cloog-${CLOOG_VER}.tar.gz && mv ${WORKDIR}/cloog-${CLOOG_VER} ${S}/cloog ) || die "cloog setup fail"
		( unpack isl-${ISL_VER}.tar.xz && mv ${WORKDIR}/isl-${ISL_VER} ${S}/isl ) || die "isl setup fail"
	fi

	# GNAT ada support
	if use ada ; then
		if use amd64; then
			unpack $GNAT64 || die "ada setup failed"
		elif use x86; then
			unpack $GNAT32 || die "ada setup failed"
		else
			die "GNAT ada setup failed, only x86 and amd64 currently supported by this ebuild. Patches welcome!"
		fi
	fi

	# gdc D support -- now included in mainline
	if false && use d ; then
		O_EGIT_BRANCH="${EGIT_BRANCH}"
		O_EGIT_COMMIT="${EGIT_COMMIT}"
		O_EGIT_COMMIT_DATE="${EGIT_COMMIT_DATE}"
		EGIT_BRANCH="${DLANG_BRANCH}"
		EGIT_COMMIT="${DLANG_COMMIT}"
		EGIT_COMMIT_DATE="${DLANG_COMMIT_DATE}"
		git-r3_fetch "${DLANG_REPO_URI}"
		git-r3_checkout "${DLANG_REPO_URI}" "${DLANG_CHECKOUT_DIR}"
		EGIT_BRANCH="${O_EGIT_BRANCH}"
		EGIT_COMMIT="${O_EGIT_COMMIT}"
		EGIT_COMMIT_DATE="${O_EGIT_COMMIT_DATE}"
	fi

	cd $S
	mkdir ${WORKDIR}/objdir
}

eapply_gentoo() {
	eapply "${GENTOO_PATCHES_DIR}/${1}" || die "${1} patch fail"
}

src_prepare() {
	# Run preperations for dependencies first
	_gcc_prepare_mpfr

	# Patch from release to svn branch tip for backports
	if [ -n "${GCC_SVN_PATCH}" ]; then
		eapply "${GCC_SVN_PATCH}" || die "gcc svn patch fail"
	fi
	# For some reason, when upgrading gcc, the gcc Makefile will install stuff

	# like crtbegin.o into a subdirectory based on the name of the currently-installed
	# gcc version, rather than *our* gcc version. Manually fix this:

	sed -i -e "s/^version :=.*/version := ${GCC_CONFIG_VER}/" ${S}/libgcc/Makefile.in || die

	if ! use vanilla; then

		# Prevent libffi from being installed
		sed -i -e 's/\(install.*:\) install-.*recursive/\1/' "${S}"/libffi/Makefile.in || die
		sed -i -e 's/\(install-data-am:\).*/\1/' "${S}"/libffi/include/Makefile.in || die

		# We use --enable-version-specific-libs with ./configure. This
		# option is designed to place all our libraries into a sub-directory
		# rather than /usr/lib*.  However, this option, even through 4.8.0,
		# does not work 100% correctly without a small fix for
		# libgcc_s.so. See: http://gcc.gnu.org/bugzilla/show_bug.cgi?id=32415.
		# So, we apply a small patch to get this working:

		eapply "${FILESDIR}/gcc-4.6.4-fix-libgcc-s-path-with-vsrl.patch" || die "patch fail"

		if use dev_extra_warnings ; then
			eapply_gentoo "$(set +f ; cd "${GENTOO_PATCHES_DIR}" && echo ??_all_default-warn-format-security.patch )"
			eapply_gentoo "$(set +f ; cd "${GENTOO_PATCHES_DIR}" && echo ??_all_default-warn-trampolines.patch )"
			if use test ; then
				ewarn "USE=dev_extra_warnings enables warnings by default which are known to break gcc's tests!"
			fi
			einfo "Additional warnings enabled by default, this may break some tests and compilations with -Werror."
		fi

		if [ -n "$GENTOO_PATCHES_VER" ]; then
			einfo "Applying Gentoo patches ..."
			for my_patch in ${GENTOO_PATCHES[*]} ; do
				eapply_gentoo "${my_patch}"
			done
		fi

		#use bootstrap-lto && eapply "${FILESDIR}/Fix-bootstrap-miscompare-with-LTO-bootstrap-PR85571.patch"

		# Harden things up:
		_gcc_prepare_harden
	fi

	is_crosscompile && _gcc_prepare_cross

	# Ada gnat compiler bootstrap preparation
	use ada && _gcc_prepare_gnat

	# Prepare GDC for d-lang support
	use d && _gcc_prepare_gdc

	# Must be called in src_prepare by EAPI6
	eapply_user
}

_gcc_prepare_mpfr() {
	if [ -n "${MPFR_PATCH_VER}" ];  then
		[ -f "${MPFR_PATCH_FILE}" ] || die "Couldn't find mpfr patch '${MPFR_PATCH_FILE}"
		pushd "${S}/mpfr" > /dev/null || die "Couldn't change to mpfr source directory."
		patch -N -Z -p1 < "${MPFR_PATCH_FILE}" || die "Failed to apply mpfr patch '${MPFR_PATCH_FILE}'."
		popd > /dev/null
	fi
}

_gcc_prepare_harden() {
	local gcc_hard_flags=""
	[ ${GCC_MAJOR} -eq 6 ] && _gcc_prepare_harden_7
	[ ${GCC_MAJOR} -eq 7 ] && _gcc_prepare_harden_7
	[ ${GCC_MAJOR} -eq 8 ] && _gcc_prepare_harden_8

	# Enable FORTIFY_SOURCE by default
	eapply_gentoo "$(set +f ; cd "${GENTOO_PATCHES_DIR}" && echo ??_all_default-fortify-source.patch )"
	
	# Selectively enable features from hardening patches
	use ssp_all && gcc_hard_flags+=" -DENABLE_DEFAULT_SSP_ALL"
	use link_now && gcc_hard_flags+=" -DENABLE_DEFAULT_LINK_NOW"


	sed -e '/^ALL_CFLAGS/iHARD_CFLAGS = ' \
		-e 's|^ALL_CFLAGS = |ALL_CFLAGS = $(HARD_CFLAGS) |' \
		-i "${S}"/gcc/Makefile.in

	sed -e '/^ALL_CXXFLAGS/iHARD_CFLAGS = ' \
		-e 's|^ALL_CXXFLAGS = |ALL_CXXFLAGS = $(HARD_CFLAGS) |' \
		-i "${S}"/gcc/Makefile.in

	sed -i -e "/^HARD_CFLAGS = /s|=|= ${gcc_hard_flags} |" "${S}"/gcc/Makefile.in || die
}

_gcc_prepare_harden_6() {
	_gcc_prepare_harden_6_7
}

_gcc_prepare_harden_7() {
	_gcc_prepare_harden_6_7
}

_gcc_prepare_harden_6_7() {
	cat "${GENTOO_PATCHES_DIR}/$(set +f ; cd "${GENTOO_PATCHES_DIR}" && echo ??_all_extra-options.patch )" \
		| sed \
			-e '/#ifdef ENABLE_DEFAULT_SSP/,/# endif/ { s/EXTRA_OPTIONS/ENABLE_DEFAULT_SSP_ALL/ }' \
			-e '/#define STACK_CHECK_SPEC/,/#define LINK_NOW_SPEC/ { s/EXTRA_OPTIONS/ENABLE_DEFAULT_LINK_NOW/ }' \
			-e '/CPP_SPEC/,/CC1_SPEC/ { s/EXTRA_OPTIONS/ENABLE_DEFAULT_STACK_CHECK/ }' \
			-e 's/#ifndef EXTRA_OPTIONS/#ifndef SANE_FSTRICT_OVERFLOW/g' \
		> "${T}/hardening-options.patch"
		eapply "${T}/hardening-options.patch"
		gcc_hard_flags+=" -DSANE_FSTRICT_OVERFLOW"
}

_gcc_prepare_harden_8() {
	# Modify gentoo patch to use our more specific hardening flags.
	cat "${GENTOO_PATCHES_DIR}/$(set +f ; cd "${GENTOO_PATCHES_DIR}" && echo ??_all_extra-options.patch )" \
		| sed \
			-e 's/EXTRA_OPTIONS/ENABLE_DEFAULT_LINK_NOW/g' \
			-e 's/ENABLE_ESP/ENABLE_DEFAULT_SCP/g' \
		> "${T}/hardening-options.patch"
	eapply "${T}/hardening-options.patch"
	use stack_clash_protection && gcc_hard_flags+=" -DENABLE_DEFAULT_SCP"
}

_gcc_prepare_cross() {
	case ${CTARGET} in
		*-linux) TARGET_LIBC=no-idea;;
		*-dietlibc) TARGET_LIBC=dietlibc;;
		*-elf|*-eabi) TARGET_LIBC=newlib;;
		*-freebsd*) TARGET_LIBC=freebsd-lib;;
		*-gnu*) TARGET_LIBC=glibc;;
		*-klibc) TARGET_LIBC=klibc;;
		*-musl*) TARGET_LIBC=musl;;
		*-uclibc*) TARGET_LIBC=uclibc;;
		avr*) TARGET_LIBC=avr-libc;;
	esac
	export TARGET_LIBC

	# if we don't tell it where to go, libcc1 stuff ends up in ${ROOT}/usr/lib (or rather dies colliding)
	sed -e 's%cc1libdir = .*%cc1libdir = '"${ROOT}${PREFIX}"'/$(host_noncanonical)/$(target_noncanonical)/lib/$(gcc_version)%' \
		-e 's%plugindir = .*%plugindir = '"${ROOT}${PREFIX}"'/lib/gcc/$(target_noncanonical)/$(gcc_version)/plugin%' \
		-i "${WORKDIR}/${P}/libcc1"/Makefile.{am,in}
	if [[ ${CTARGET} == avr* ]]; then
		sed -e 's%native_system_header_dir=/usr/include%native_system_header_dir=/include%' -i "${WORKDIR}/${P}/gcc/config.gcc"
	fi
}

_gcc_prepare_gnat() {
	export GNATBOOT="${S}/gnatboot"

	if [ -f  gcc/ada/libgnat/s-parame.adb ] ; then
		einfo "Patching ada stack handling..."
		grep -q -e '-- Default_Sec_Stack_Size --' gcc/ada/libgnat/s-parame.adb && eapply "${FILESDIR}/Ada-Integer-overflow-in-SS_Allocate.patch"
	fi

	if use amd64; then
		einfo "Preparing gnat64 for ada:"
		make -C ${WORKDIR}/${GNAT64%%.*} ins-all prefix=${S}/gnatboot > /dev/null || die "ada preparation failed"
		find ${S}/gnatboot -name ld -exec mv -v {} {}.old \;
	elif use x86; then
		einfo "Preparing gnat32 for ada:"
		make -C ${WORKDIR}/${GNAT32%%.*} ins-all prefix=${S}/gnatboot > /dev/null || die "ada preparation failed"
		find ${S}/gnatboot -name ld -exec mv -v {} {}.old \;
	else
		die "GNAT ada setup failed, only x86 and amd64 currently supported by this ebuild. Patches welcome!"
	fi

	# Setup additional paths as needed before we start.
	use ada && export PATH="${GNATBOOT}/bin:${PATH}"
}

_gcc_prepare_gdc() {
	return 0
	# Now included in mainline, below not needed
	pushd "${DLANG_CHECKOUT_DIR}" > /dev/null || die "Could not change to GDC directory."

		# Apply patches to the patches to account for gentoo patches modifications to configure changing line numbers
		local _gdc_gentoo_compat_patch="${FILESDIR}/lang/d/${PF}-gdc-gentoo-compatibility.patch"
		[ -f "${_gdc_gentoo_compat_patch}" ] && eapply "$_gdc_gentoo_compat_patch"

		./setup-gcc.sh ../gcc-${PV} || die "Could not setup GDC."
	popd > /dev/null
}

gcc_conf_lang_opts() {
	# Determine language support:
	local conf_gcc_lang=""
	local GCC_LANG="c,c++"
	if use objc; then
		GCC_LANG+=",objc"
		use objc-gc && conf_gcc_lang+=" --enable-objc-gc"
		use objc++ && GCC_LANG+=",obj-c++"
	fi

	use fortran && GCC_LANG+=",fortran" || conf_gcc_lang+=" --disable-libquadmath"

	use go && GCC_LANG+=",go"

	use ada && GCC_LANG+=",ada" && conf_gcc_lang+=" CC=${GNATBOOT}/bin/gcc CXX=${GNATBOOT}/bin/g++ AR=${GNATBOOT}/bin/gcc-ar AS=as LD=ld NM=${GNATBOOT}/bin/gcc-nm RANLIB=${GNATBOOT}/bin/gcc-ranlib"

	use d && GCC_LANG+=",d"

	conf_gcc_lang+=" --enable-languages=${GCC_LANG} --disable-libgcj"

	printf -- "${conf_gcc_lang}"
}

# ARM
gcc_conf_arm_opts() {
	# Skip the rest if not an arm target
	[[ ${CTARGET} == arm* ]] || return

	local conf_gcc_arm=""
	local arm_arch=${CTARGET%%-*}
	local a
	# Remove trailing endian variations first: eb el be bl b l
	for a in e{b,l} {b,l}e b l ; do
		if [[ ${arm_arch} == *${a} ]] ; then
			arm_arch=${arm_arch%${a}}
			break
		fi
	done

	# Convert armv7{a,r,m} to armv7-{a,r,m}
	[[ ${arm_arch} == armv7? ]] && arm_arch=${arm_arch/7/7-}

	# See if this is a valid --with-arch flag
	if (srcdir=${S}/gcc target=${CTARGET} with_arch=${arm_arch};
		. "${srcdir}"/config.gcc) &>/dev/null
	then
		conf_gcc_arm+=" --with-arch=${arm_arch}"
	fi

	# Enable hardvfp
	local float="hard"
	local default_fpu=""

	case "${CTARGET}" in
		*[-_]softfloat[-_]*) float="soft" ;;
		*[-_]softfp[-_]*) float="softfp" ;;
		armv[56]*) default_fpu="vfpv2" ;;
		armv7ve*) default_fpu="vfpv4-d16" ;;
		armv7*) default_fpu="vfpv3-d16" ;;
		amrv8*) default_fpu="fp-armv8" ;;
	esac
	
	conf_gcc_arm+=" --with-float=$float"
	[ -z "${MFPU}" ] && [ -n "${default_fpu}" ] && conf_gcc_arm+=" --with-fpu=${default_fpu}"

	printf -- "${conf_gcc_arm}"
}

gcc_conf_cross_options() {
	local conf_gcc_cross
	conf_gcc_cross+=" --disable-libgomp --disable-bootstrap --enable-poison-system-directories"

	if [[ ${CTARGET} == avr* ]]; then
		conf_gcc_cross+=" --disable-__cxa_atexit"
	else
		conf_gcc_cross+=" --enable-__cxa_atexit"
	fi

	# Handle bootstrapping cross-compiler and libc in lock-step
	if ! has_version ${CATEGORY}/${TARGET_LIBC}; then
		# we are building with libc that is not installed:
		conf_gcc_cross+=" --disable-shared --disable-libatomic --disable-threads --without-headers --disable-libstdcxx"
	elif has_version "${CATEGORY}/${TARGET_LIBC}[headers-only]"; then
		# libc installed, but has USE="crosscompile_opts_headers-only" to only install headers:
		conf_gcc_cross+=" --disable-shared --disable-libatomic --with-sysroot=${PREFIX}/${CTARGET} --disable-libstdcxx"
	else
		# libc is installed:
		conf_gcc_cross+=" --with-sysroot=${PREFIX}/${CTARGET} --enable-libstdcxx-time"
	fi

	printf -- "${conf_gcc_cross}"
}

src_configure() {

	local confgcc
	if is_crosscompile || tc-is-cross-compiler; then
		confgcc+=" --target=${CTARGET}"
	fi
	if is_crosscompile; then
		confgcc+="$(gcc_conf_cross_options)"
	else
		confgcc+=" --enable-threads=posix --enable-__cxa_atexit --enable-libstdcxx-time"
		confgcc+=" $(use_enable openmp libgomp)"
		confgcc+=" $(use_enable bootstrap) --enable-shared"
	fi

	[[ -n ${CBUILD} ]] && confgcc+=" --build=${CBUILD}"

	confgcc+=" $(use_enable sanitize libsanitizer)"
	confgcc+=" $(use_enable pie default-pie)"
	confgcc+=" $(use_enable ssp default-ssp)"
	! use pch && confgcc+=" --disable-libstdcxx-pch"
	use graphite && confgcc+=" --disable-isl-version-check"

	use vtv && confgcc+=" --enable-vtable-verify --enable-libvtv"
	! use vtv && confgcc+=" --disable-vtable-verify --disable-libvtv"

	use libssp || export gcc_cv_libc_provides_ssp=yes

	local branding="Funtoo ${PVR}"

	confgcc+=" --with-python-dir=${DATAPATH/$PREFIX/}/python"
	use nls && confgcc+=" --enable-nls --with-included-gettext" || confgcc+=" --disable-nls"

	use generic_host || confgcc+="${MARCH:+ --with-arch=${MARCH}}${MCPU:+ --with-cpu=${MCPU}}${MTUNE:+ --with-tune=${MTUNE}}${MFPU:+ --with-fpu=${MFPU}}"
	P= cd ${WORKDIR}/objdir && ../gcc-${PV}/configure \
		${BUILD_CONFIG:+--with-build-config="${BUILD_CONFIG}"} \
		$(use_enable libssp) \
		$(use_enable multilib) \
		--enable-version-specific-runtime-libs \
		--prefix=${PREFIX} \
		--bindir=${BINPATH} \
		--includedir=${LIBPATH}/include \
		--datadir=${DATAPATH} \
		--mandir=${DATAPATH}/man \
		--infodir=${DATAPATH}/info \
		--with-gxx-include-dir=${STDCXX_INCDIR} \
		--enable-clocale=gnu \
		--host=$CHOST \
		--enable-obsolete \
		--disable-werror \
		--enable-libmudflap \
		--enable-secureplt \
		--enable-lto \
		--with-system-zlib \
		$(use_with graphite cloog) \
		--with-bugurl=http://bugs.funtoo.org \
		--with-pkgversion="$branding" \
		$(gcc_checking_opts stage1) $(gcc_checking_opts) \
		$(gcc_conf_lang_opts) $(gcc_conf_arm_opts) $confgcc \
		|| die "configure fail"

	is_crosscompile && gcc_conf_cross_post
}

gcc_conf_cross_post() {
	if use arm ; then		
		sed -i "s/none-/${CHOST%%-*}-/g" ${WORKDIR}/objdir/Makefile || die
	fi

}

src_compile() {
	cd $WORKDIR/objdir
	unset ABI
	emake P= LIBPATH="${LIBPATH}" ${GCC_TARGET} || die "compile fail"
}

src_test() {
	cd "${WORKDIR}/objdir"
	unset ABI
	local tests_failed=0
	if is_crosscompile || tc-is-cross-compiler; then
		ewarn "Running tests on simulator for cross-compiler not yet supported by this ebuild."
	else
		( ulimit -s 65536 && ${MAKE:-make} ${MAKEOPTS} LIBPATH="${ED%/}/${LIBPATH}" -k check RUNTESTFLAGS="-v -v -v" 2>&1 | tee ${T}/make-check-log ) || tests_failed=1
		"../${S##*/}/contrib/test_summary" 2>&1 | tee "${T}/gcc-test-summary.out"
		[ ${tests_failed} -eq 0 ] || die "make -k check failed"
	fi
}

create_gcc_env_entry() {
	dodir /etc/env.d/gcc
	local gcc_envd_base="/etc/env.d/gcc/${CTARGET}-${GCC_CONFIG_VER}"
	local gcc_envd_file="${D}${gcc_envd_base}"
	if [ -z $1 ]; then
		gcc_specs_file=""
	else
		gcc_envd_file="$gcc_envd_file-$1"
		gcc_specs_file="${LIBPATH}/$1.specs"
	fi
	cat <<-EOF > ${gcc_envd_file}
	GCC_PATH="${BINPATH}"
	LDPATH="${LIBPATH}:${LIBPATH}/32"
	MANPATH="${DATAPATH}/man"
	INFOPATH="${DATAPATH}/info"
	STDCXX_INCDIR="${STDCXX_INCDIR##*/}"
	GCC_SPECS="${gcc_specs_file}"
	EOF

	if is_crosscompile; then
		echo "CTARGET=\"${CTARGET}\"" >> ${gcc_envd_file}
	fi
}

linkify_compiler_binaries() {
	dodir ${PREFIX}/bin
	cd "${D}"${BINPATH}
	# Ugh: we really need to auto-detect this list.
	#	   It's constantly out of date.

	local binary_languages="cpp gcc g++ c++ gcov"
	local gnat_bins="gnat gnatbind gnatchop gnatclean gnatfind gnatkr gnatlink gnatls gnatmake gnatname gnatprep gnatxref"

	use go && binary_languages="${binary_languages} gccgo"
	use fortran && binary_languages="${binary_languages} gfortran"
	use ada && binary_languages="${binary_languages} ${gnat_bins}"
	use d && binary_languages="${binary_languages} gdc"

	for x in ${binary_languages} ; do
		[[ -f ${x} ]] && mv ${x} ${CTARGET}-${x}

		if [[ -f ${CTARGET}-${x} ]] ; then
			if ! is_crosscompile; then
				ln -sf ${CTARGET}-${x} ${x}
				dosym ${BINPATH}/${CTARGET}-${x} ${PREFIX}/bin/${x}-${GCC_CONFIG_VER}
			fi
			# Create version-ed symlinks
			dosym ${BINPATH}/${CTARGET}-${x} ${PREFIX}/bin/${CTARGET}-${x}-${GCC_CONFIG_VER}
		fi

		if [[ -f ${CTARGET}-${x}-${GCC_CONFIG_VER} ]] ; then
			rm -f ${CTARGET}-${x}-${GCC_CONFIG_VER}
			ln -sf ${CTARGET}-${x} ${CTARGET}-${x}-${GCC_CONFIG_VER}
		fi
	done
}

tasteful_stripping() {
	# Now do the fun stripping stuff
	[[ ! is_crosscompile ]] && \
		env RESTRICT="" CHOST=${CHOST} prepstrip "${D}${BINPATH}" ; \
		env RESTRICT="" CHOST=${CTARGET} prepstrip "${D}${LIBPATH}"
	# gcc used to install helper binaries in lib/ but then moved to libexec/
	[[ -d ${D}${PREFIX}/libexec/gcc ]] && \
		env RESTRICT="" CHOST=${CHOST} prepstrip "${D}${PREFIX}/libexec/gcc/${CTARGET}/${GCC_CONFIG_VER}"
}

doc_cleanups() {
	local cxx_mandir=$(find "${WORKDIR}/objdir/${CTARGET}/libstdc++-v3" -name man)
	if [[ -d ${cxx_mandir} ]] ; then
		# clean bogus manpages #113902
		find "${cxx_mandir}" -name '*_build_*' -exec rm {} \;
		( set +f ; cp -r "${cxx_mandir}"/man? "${D}/${DATAPATH}"/man/ )
	fi

	# Remove info files if we don't want them.
	if is_crosscompile || ! use doc || has noinfo ${FEATURES} ; then
		rm -r "${D}/${DATAPATH}"/info
	else
		prepinfo "${DATAPATH}"
	fi

	# Strip man files too if 'noman' feature is set.
	if is_crosscompile || has noman ${FEATURES} ; then
		rm -r "${D}/${DATAPATH}"/man
	else
		prepman "${DATAPATH}"
	fi
}

cross_toolchain_env_setup() {

	# old xcompile bashrc stuff here
	dosym /etc/localtime /usr/${CTARGET}/etc/localtime
	for file in /usr/lib/gcc/${CTARGET}/${GCC_CONFIG_VER}/libstdc*; do
		dosym "$file" "/usr/${CTARGET}/lib/$(basename $file)"
	done
	mkdir -p /etc/revdep-rebuild
	insinto "/etc/revdep-rebuild"
	string="SEARCH_DIRS_MASK=\"/usr/${CTARGET} "
	for dir in /usr/lib/gcc/${CTARGET}/*; do
		string+="$dir "
	done
	for dir in /usr/lib64/gcc/${CTARGET}/*; do
		string+="$dir "
	done
	string="${string%?}"
	string+='"' 
	if [[ -e /etc/revdep-rebuild/05cross-${CTARGET} ]] ; then
		string+=" $(cat /etc/revdep-rebuild/05cross-${CTARGET}|sed -e 's/SEARCH_DIRS_MASK=//')"
	fi
	printf "$string">05cross-${CTARGET}
	doins 05cross-${CTARGET}
}
				
src_install() {
	S=$WORKDIR/objdir; cd $S

# PRE-MAKE INSTALL SECTION:

	# Don't allow symlinks in private gcc include dir as this can break the build
	( set +f ; find gcc/include*/ -type l -delete 2>/dev/null )

	# Remove generated headers, as they can cause things to break
	# (ncurses, openssl, etc).
	while read x; do
		grep -q 'It has been auto-edited by fixincludes from' "${x}" \
			&& echo "Removing auto-generated header: $x" \
			&& rm -f "${x}"
	done < <(find gcc/include*/ -name '*.h')

# MAKE INSTALL SECTION:

	make -j1 DESTDIR="${D}" install || die

# POST MAKE INSTALL SECTION:
	if is_crosscompile; then
		cross_toolchain_env_setup
	else
		# Basic sanity check
		local EXEEXT
		eval $(grep ^EXEEXT= "${WORKDIR}"/objdir/gcc/config.log)
		[[ -r ${D}${BINPATH}/gcc${EXEEXT} ]] || die "gcc not found in ${D}"

		# Install compat wrappers
		exeinto "${DATAPATH}"
		( set +f ; doexe "${FILESDIR}"/c{89,99} || die )	
	fi
	
	# Setup env.d entry 
	dodir /etc/env.d/gcc
	create_gcc_env_entry

# CLEANUPS:

	# Punt some tools which are really only useful while building gcc
	find "${D}" -name install-tools -prune -type d -exec rm -rf "{}" \; 2>/dev/null
	# This one comes with binutils
	find "${D}" -name libiberty.a -delete 2>/dev/null
	# prune empty dirs left behind
	find "${D}" -depth -type d -delete 2>/dev/null
	# ownership fix:
	chown -R root:0 "${D}"${LIBPATH} 2>/dev/null

	linkify_compiler_binaries
	tasteful_stripping
	
	# Remove python files in the lib path
	find "${D}/${LIBPATH}" -name "*.py" -type f -exec rm "{}" \; 2>/dev/null
	
	# Remove unwanted docs and prepare the rest for installation
	doc_cleanups
	
	# Cleanup undesired libtool archives
	find "${D}" \
		'(' \
			-name 'libstdc++.la' -o -name 'libstdc++fs.la' -o -name 'libsupc++.la' -o \
			-name 'libcc1.la' -o -name 'libcc1plugin.la' -o -name 'libcp1plugin.la' -o \
			-name 'libgomp.la' -o -name 'libgomp-plugin-*.la' -o \
			-name 'libgfortran.la' -o -name 'libgfortranbegin.la' -o \
			-name 'libmpx.la' -o -name 'libmpxwrappers.la' -o \
			-name 'libitm.la' -o -name 'libvtv.la' -o -name 'lib*san.la' \
		')' -type f -delete 2>/dev/null

	# replace gcc_movelibs - currently handles only libcc1:
	( set +f
		einfo -- "Removing extraneous libtool '.la' files from '${PREFIX}/lib*}'."
		rm ${D%/}${PREFIX}/lib{,32,64}/*.la 2>/dev/null
		einfo -- "Relocating libs to '${LIBPATH}':"
		for l in "${D%/}${PREFIX}"/lib{,32,64}/* ; do
			[ -f "${l}" ] || continue
			mydir="${l%/*}" ; myfile="${l##*/}"
			einfo -- "Moving '${myfile}' from '${mydir#${D}}' to '${LIBPATH}'."
			cd "${mydir}" && mv "${myfile}" "${D}${LIBPATH}/${myfile}" 2>/dev/null || die
		done
	)

	# the .la files that are installed have weird embedded single quotes around abs
	# paths on the dependency_libs line. The following code finds and fixes them:

	for x in $(find ${D}${LIBPATH} -iname '*.la'); do
		dep="$(cat $x | grep ^dependency_libs)"
		[ "$dep" == "" ] && continue
		inner_dep="${dep#dependency_libs=}"
		inner_dep="${inner_dep//\'/}"
		inner_dep="${inner_dep# *}"
		sed -i -e "s:^dependency_libs=.*$:dependency_libs=\'${inner_dep}\':g" $x || die
	done

	# Don't scan .gox files for executable stacks - false positives
	if use go; then
		export QA_EXECSTACK="${PREFIX#/}/lib*/go/*/*.gox"
		export QA_WX_LOAD="${PREFIX#/}/lib*/go/*/*.gox"
	fi

	# Disable RANDMMAP so PCH works.
	[[ ! is_crosscompile ]] && \
		pax-mark -r "${D}${PREFIX}/libexec/gcc/${CTARGET}/${GCC_CONFIG_VER}/cc1" ; \
		pax-mark -r "${D}${PREFIX}/libexec/gcc/${CTARGET}/${GCC_CONFIG_VER}/cc1plus"
}

pkg_postrm() {
	# clean up the cruft left behind by cross-compilers
	if is_crosscompile ; then
		if [[ -z $(ls "${ROOT}etc/env.d/gcc"/${CTARGET}* 2>/dev/null) ]] ; then
			( set +f
				rm -f "${ROOT}etc/env.d/gcc"/config-${CTARGET} 2>/dev/null
				rm -f "${ROOT}etc/env.d"/??gcc-${CTARGET} 2>/dev/null
				rm -f "${ROOT}usr/bin"/${CTARGET}-{gcc,{g,c}++}{,32,64} 2>/dev/null
			)
		fi
		return 0
	fi
}

pkg_postinst() {
	if is_crosscompile; then
			mkdir -p "${ROOT}etc/env.d"
			cat > "${ROOT}etc/env.d/05gcc-${CTARGET}" <<- EOF
				PATH=${BINPATH}
				ROOTPATH=${BINPATH}
			EOF
	fi

	# hack from gentoo - should probably be handled better:
	( set +f ; cp "${ROOT}${DATAPATH}"/c{89,99} "${ROOT}${PREFIX}/bin/" 2>/dev/null )

	PATH="${BINPATH}:${PATH}"
	export PATH
	compiler_auto_enable ${PV} ${CTARGET}
}



# GCC internal self checking options
# Usage: gcc_checking_opts [stage1]
gcc_checking_opts() {
	local stage1="${1}${1:+_}"

	local opts check checks
	# Setting checking_no overrides all other checks
	if use ${stage1}checking_no ; then
		opts="no"
	else
		# Priority is all > yes > release
		if use ${stage1}checking_all ; then
			checks="${CHECKS_ALL}"
		elif use ${stage1}checking_yes ; then
			checks="${CHECKS_YES}"
		elif use ${stage1}checking_release ; then
			checks="${CHECKS_RELEASE}"
		fi

		# Check if explict use flags are set for any valid checks
		for check in ${CHECKS_ALL} ${CHECKS_VALGRIND} ; do
			# Check if the flag is enabled and add to list if not there; force extra to set the same for both scopes.
			if use ${stage1}checking_${check} || ( [ -n "${CHECKS_EXTRA}" ] && [ "${check}" = "extra" ] && ( use stage1_checking_extra || use checking_extra ) ) ; then
				has check "${checks}" || checks="${checks} ${check}"
			fi
		done

		# If no checking has been defined, set defaults
		if [ -z "${checks}" ] ; then
			if [ -n "${stage1}" ] ; then
				checks="${CHECKS_YES}"
			else
				checks="${CHECKS_RELEASE}"
			fi
		fi

		# build our opts string
		for check in ${checks} ; do
			opts="${opts}${opts:+,}${check}"
		done
	fi


	printf -- "--enable-${stage1:+${stage1%_}-}checking=${opts}"
}
