# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGIT_REPO_URI="https://anongit.freedesktop.org/git/mesa/mesa.git"

if [[ ${PV} = 9999 ]]; then
	GIT_ECLASS="git-r3"
	EXPERIMENTAL="true"
fi

PYTHON_COMPAT=( python3_{4,5,6,7} )

inherit meson eutils llvm python-any-r1 pax-utils ${GIT_ECLASS}

OPENGL_DIR="xorg-x11"

MY_P="${P/_/-}"

DESCRIPTION="OpenGL-like graphic library for Linux"
HOMEPAGE="https://www.mesa3d.org/ https://mesa.freedesktop.org/"

if [[ $PV == 9999 ]]; then
	SRC_URI=""
else
	SRC_URI="https://mesa.freedesktop.org/archive/${MY_P}.tar.xz"
	KEYWORDS="*"
fi

LICENSE="MIT"
SLOT="0"

RADEON_CARDS="r100 r200 r300 r600 radeonsi"
INTEL_CARDS="i915 i965"

ALL_DRI_DRIVERS="i915 i965 r100 r200 nouveau swrast"
for card in ${ALL_DRI_DRIVERS% swrast*}; do
	ALL_DRI_CARDS+=" video_cards_${card}"
done

ALL_GALLIUM_DRIVERS="pl111 radeonsi r300 r600 nouveau freedreno vc4 v3d etnaviv imx tegra i915 svga virgl swr swrast"
for card in ${ALL_GALLIUM_DRIVERS% swrast*}; do
	case "$card" in
		etnaviv) card="vivante" ;;
		svga) card="vmware" ;;
		*) : ;;
	esac
	ALL_GALLIUM_CARDS+=" video_cards_gallium-${card}"
done

ALL_SWR_ARCHES="avx avx2 knl skx"
IUSE_SWR_CPUFLAGS="cpu_flags_x86_avx cpu_flags_x86_avx2 cpu_flags_x86_avx512er cpu_flags_x86_avx512bw"

IUSE_VIDEO_CARDS="${ALL_DRI_CARDS} ${ALL_GALLIUM_CARDS}"

IUSE_GL="+glvnd +opengl +glx +egl +gles1 +gles2"
IUSE_PLATFORMS="+X +drm wayland +surfaceless android haiku"
IUSE_CL="opencl +ocl-icd"
IUSE_MEDIA="video_cards_vaapi video_cards_vdpau video_cards_xvmc video_cards_xa video_cards_openmax"


IUSE="${IUSE_VIDEO_CARDS}
	${IUSE_DRIVER_OPTS}
	${IUSE_GL}
	${IUSE_VULKAN}
	${IUSE_PLATFORMS}
	${IUSE_CL}
	${IUSE_MEDIA}
	${IUSE_SWR_CPUFLAGS}
	+gbm
	+llvm +shader-cache
	d3d9
	extra-hud sensors
	pax_kernel pic selinux
	debug unwind valgrind
	alternate-path
	test
	video_cards_amdgpu
	video_cards_dri3
	video_cards_intel
	video_cards_radeon
	video_cards_vulkan-intel
	video_cards_vulkan-amdgpu
	video_cards_osmesa
	video_cards_gallium-osmesa
	video_cards_swrast
	video_cards_gallium-swrast
	video_cards_virgl
	video_cards_gallium-i915

"

REQUIRED_USE_APIS="
	gles1? ( opengl )
	gles2? ( opengl )
	glx? ( X opengl )
	glvnd? ( || ( egl glx ) )
"

REQUIRED_USE="
	d3d9?	( video_cards_gallium-swrast )
	opencl? (
		llvm
		|| ( ${ALL_GALLIUM_CARDS} )
	)
"

# We want to ensure that "at most one" of i915 and gallium-i915 are chosen.
# There are a few other drivers where you can't build both, but have to choose one.
# Then we want to ensure that "intel" and "radeon" are enabled in VIDEO_CARDS
# if you are enabling any intel or radeon-related settings. This is for sanity
# with libdrm and others that use "video_cards_intel" and "video_cards_radeon".

REQUIRED_USE="
	$REQUIRED_USE
	?? ( video_cards_i915 video_cards_gallium-i915 )
	?? ( video_cards_swrast video_cards_gallium-swrast )
	?? ( video_cards_osmesa video_cards_gallium-osmesa )
	video_cards_vulkan-intel? ( video_cards_intel )
	video_cards_i915? ( video_cards_intel )
	video_cards_i965? ( video_cards_intel )
	video_cards_gallium-i915? ( video_cards_intel )
	video_cards_r100? ( video_cards_radeon )
	video_cards_r200? ( video_cards_radeon )
	video_cards_gallium-r300? ( video_cards_radeon )
	video_cards_gallium-r600? ( video_cards_radeon )
	video_cards_amdgpu? ( video_cards_radeon )
	video_cards_vulkan-amdgpu? ( video_cards_radeon )
"

REQUIRED_USE="
	$REQUIRED_USE
	wayland? ( egl gbm )
	video_cards_gallium-swrast? ( llvm )
	video_cards_gallium-swr? ( || ( ${IUSE_SWR_CPUFLAGS} ) )
	video_cards_gallium-imx?	( video_cards_gallium-vivante )
	video_cards_gallium-tegra? ( video_cards_gallium-nouveau )
	video_cards_gallium-r300?	( x86? ( llvm ) amd64? ( llvm ) )
	video_cards_gallium-radeonsi?	( llvm egl? ( || ( drm surfaceless ) ) )
	video_cards_gallium-pl111? ( video_cards_gallium-vc4 )
	video_cards_gallium-virgl? ( egl? ( || ( drm surfaceless ) ) )
	video_cards_gallium-vivante? ( gbm )
"

# keep blocks in rdepend for binpkg
RDEPEND="
	!<x11-base/xorg-server-1.7
	glvnd? ( >=media-libs/libglvnd-0.2.0 )
	>=app-eselect/eselect-opengl-1.3.0
	>=dev-libs/expat-2.1.0-r3:=
	>=sys-libs/zlib-1.2.8

	X? (
		>=x11-libs/libX11-1.6.2:=
		>=x11-libs/libXext-1.3.2:=
		>=x11-libs/libXdamage-1.1.4-r1:=
		x11-libs/libXfixes:=
		video_cards_dri3? (
			>=x11-libs/libxcb-1.13:=
			>=x11-base/xcb-proto-1.13:=
		)
		!video_cards_dri3? ( >=x11-libs/libxcb-1.9.3:= )
		>=x11-libs/libXxf86vm-1.1.3:=
		>=x11-libs/libxshmfence-1.1:=
		drm? ( >=x11-proto/dri2proto-2.8:= )
		>=x11-proto/glproto-1.4.14:=
		drm? (
			>=x11-libs/libXrandr-1.3:=
			>=x11-base/xcb-proto-1.13:=
			>=x11-libs/libxcb-1.13:=
		)
	)

	wayland? (
		>=dev-libs/wayland-protocols-1.15
		>=dev-libs/wayland-1.15.0:=
	)

	sensors? ( sys-apps/lm_sensors )
	unwind? ( sys-libs/libunwind )
	llvm? (
		video_cards_gallium-radeonsi? (
			virtual/libelf:0=
		)
		video_cards_gallium-r600? (
			virtual/libelf:0=
		)
	)
	opencl? (
		dev-libs/ocl-icd
		dev-libs/libclc
		virtual/libelf:0=
	)
	video_cards_openmax? (
		>=media-libs/libomxil-bellagio-0.9.3:=
		x11-misc/xdg-utils
	)
	video_cards_vaapi? (
		>=x11-libs/libva-1.7.3:=
		video_cards_nouveau? ( !<=x11-libs/libva-vdpau-driver-0.7.4-r3 )
	)
	video_cards_vdpau? ( >=x11-libs/libvdpau-1.1:= )
	video_cards_xvmc? ( >=x11-libs/libXvMC-1.0.8:= )

	>=x11-libs/libdrm-2.4.96
	video_cards_gallium-radeonsi? ( x11-libs/libdrm[video_cards_radeon,video_cards_amdgpu] )
	video_cards_r100? ( x11-libs/libdrm[video_cards_radeon] )
	video_cards_r200? ( x11-libs/libdrm[video_cards_radeon] )
	video_cards_gallium-r300? ( x11-libs/libdrm[video_cards_radeon] )
	video_cards_gallium-r600? ( x11-libs/libdrm[video_cards_radeon] )
	video_cards_amdgpu? ( x11-libs/libdrm[video_cards_radeon,video_cards_amdgpu] )
	video_cards_vulkan-amdgpu? ( x11-libs/libdrm[video_cards_amdgpu] )
	video_cards_gallium-nouveau? ( x11-libs/libdrm[video_cards_nouveau] )
	video_cards_nouveau? ( x11-libs/libdrm[video_cards_nouveau] )
	video_cards_gallium-i915? ( x11-libs/libdrm[video_cards_intel] )
	video_cards_i915? ( x11-libs/libdrm[video_cards_intel] )
"
RDEPEND="${RDEPEND}"

# Please keep the LLVM dependency block separate. Since LLVM is slotted,
# we need to *really* make sure we're not pulling one than more slot
# simultaneously.
#
# How to use it:
# 1. List all the working slots (with min versions) in ||, newest first.
# 2. Update the := to specify *max* version, e.g. < 7.
# 3. Specify LLVM_MAX_SLOT, e.g. 6.
LLVM_MAX_SLOT=8
LLVM_DEPSTR="
	|| (
		sys-devel/llvm:8
		sys-devel/llvm:7
		>=sys-devel/llvm-6.0.1-r1
	)
	sys-devel/llvm:=
"
LLVM_DEPSTR_AMDGPU="
	|| (
		sys-devel/llvm:8[llvm_targets_AMDGPU(-)]
		sys-devel/llvm:7[llvm_targets_AMDGPU(-)]
		>=sys-devel/llvm-6.0.1-r1[llvm_targets_AMDGPU(-)]
	)
	sys-devel/llvm:=[llvm_targets_AMDGPU(-)]
"
CLANG_DEPSTR="
	|| (
		sys-devel/llvm:8[clang(+)]
		sys-devel/llvm:7[clang(+)]
		>=sys-devel/llvm-6.0.1-r1[clang(+)]
	)
	sys-devel/llvm:=[clang(+)]
"
CLANG_DEPSTR_AMDGPU="
	|| (
		sys-devel/llvm:8[clang(+),llvm_targets_AMDGPU(-)]
		sys-devel/llvm:7[clang(+),llvm_targets_AMDGPU(-)]
		>=sys-devel/llvm-6.0.1-r1[clang(+),llvm_targets_AMDGPU(-)]
	)
	sys-devel/llvm:=[clang(+),llvm_targets_AMDGPU(-)]
"
RDEPEND="${RDEPEND}
	llvm? (
		opencl? (
			video_cards_gallium-r600? (
				${CLANG_DEPSTR_AMDGPU}
			)
			!video_cards_gallium-r600? (
				video_cards_gallium-radeonsi? (
					${CLANG_DEPSTR_AMDGPU}
				)
			)
			!video_cards_gallium-r600? (
				!video_cards_gallium-radeonsi? (
					${CLANG_DEPSTR}
				)
			)
		)
		!opencl? (
			video_cards_gallium-r600? (
				${LLVM_DEPSTR_AMDGPU}
			)
			!video_cards_gallium-r600? (
				video_cards_gallium-radeonsi? (
					${LLVM_DEPSTR_AMDGPU}
				)
			)
			!video_cards_gallium-r600? (
				!video_cards_gallium-radeonsi? (
					${LLVM_DEPSTR}
				)
			)
		)
	)
"
unset {LLVM,CLANG}_DEPSTR{,_AMDGPU}

DEPEND="${RDEPEND}
	>=dev-util/meson-0.48.1
	${PYTHON_DEPS}
	opencl? (
		>=sys-devel/gcc-4.6
	)
	sys-devel/gettext
	virtual/pkgconfig
	valgrind? ( dev-util/valgrind )
	sys-devel/bison
	sys-devel/flex
	$(python_gen_any_dep ">=dev-python/mako-1.0.7[\${PYTHON_USEDEP}]")
"

S="${WORKDIR}/${MY_P}"
EGIT_CHECKOUT_DIR=${S}

QA_WX_LOAD="
x86? (
	!pic? (
		usr/lib*/libglapi.so.0.0.0
		usr/lib*/libGLESv1_CM.so.1.1.0
		usr/lib*/libGLESv2.so.2.0.0
		usr/lib*/libGL.so.1.2.0
		usr/lib*/libOSMesa.so.8.0.0
	)
)"

llvm_check_deps() {
	local flags=""

	# Don't use LLVM 6 for radv, it cause hard lockups.
	# This may be fixed with llvm 6.0.1?
	#if use video_cards_gallium-radeonsi && use vulkan && [[ ${LLVM_SLOT} == 6 ]] ; then return 1 ; fi

	# SWR doesn't like llvm-7 as of mesa 18.3.0_rc1
	if use video_cards_gallium-swr && [ ${LLVM_SLOT} -eq 0 ] ; then return 1 ; fi

	if use video_cards_gallium-r600 || use video_cards_gallium-radeonsi ; then
		flags+="llvm_targets_AMDGPU(-)"
	fi
	if [ -n "$flags" ]; then
		flags="[${flags}]"
	fi
	if use opencl; then
		has_version "sys-devel/clang:${LLVM_SLOT}${flags}" || return 1
	fi
	has_version "sys-devel/llvm:${LLVM_SLOT}${flags}"
}

pkg_setup() {
	# warning message for bug 459306
	if use llvm && has_version sys-devel/llvm[!debug=]; then
		ewarn "Mismatch between debug USE flags in media-libs/mesa and sys-devel/llvm"
		ewarn "detected! This can cause problems. For details, see bug 459306."
	fi

	if use llvm; then
		llvm_pkg_setup
	fi
	python-any-r1_pkg_setup
	export BUILD_DIR=${S}-build
}

src_prepare() {
	if [ -d "${FILESDIR}" ] && [ "$(cd "$FILESDIR" && echo "${P}"-*.patch)" != "${P}"'-*.patch' ] ; then
		eapply "${FILESDIR}/${P}"-*.patch
	fi
	[[ ${PV} == 9999 ]] && eautoreconf

	eapply_user

	export OLD_PATH="${PATH}"
}

src_configure() {
	local myconf
	local enable_dri3=false

	# Enable shader compilers
	tool_enable glsl
	tool_enable nir

	# swrast drivers
	if use video_cards_swrast; then
		dri_enable swrast
	fi
	if use video_cards_gallium-swrast; then
		gallium_enable gallium-swrast
		# swr only builds on 64bit intel
		if [[ "${ABI}" == "amd64" ]] ; then
			gallium_enable video_cards_gallium-swr swr
		fi
	fi

	# VirGL driver
	gallium_enable video_cards_gallium-virgl virgl

	# Intel cards
	if use video_cards_gallium-i915 ; then
		gallium_enable video_cards_gallium-i915 i915
	fi
	if use video_cards_i915 ; then
		dri_enable i915
	fi
	if use video_cards_vulkan-intel; then
		vulkan_enable intel
		enable_dri3="true"
	fi
	if use video_cards_i965 ; then
		dri_enable i965
	fi
	if use video_cards_i965 || use video_cards_i915 ; then
		tool_enable intel
	fi


	# Nouveau (nvidia) cards
	if use video_cards_nouveau; then
		dri_enable nouveau
	fi
	if use video_cards_gallium-nouveau; then
		gallium_enable nouveau
		gallium_enable video_cards_gallium-tegra tegra
		tool_enable nouveau
	fi

	# ATI/AMD cards
	# Older Radeon cards
	dri_enable video_cards_r100 r100
	dri_enable video_cards_r200 r200
	gallium_enable video_cards_gallium-r300 r300
	gallium_enable video_cards_gallium-r600 r600
	# Newer Radeon cards (Southern Islands/GCN1.0+)
	if use video_cards_vulkan-amdgpu; then
		vulkan_enable amd
		enable_dri3="true"
	fi
	if use video_cards_gallium-radeonsi ; then
		gallium_enable video_cards_gallium-radeonsi radeonsi
	fi
	use video_cards_dri3 && enable_dri3="true"

	# vc4/pl111 drivers
	gallium_enable video_cards_gallium-vc4 vc4
	gallium_enable video_cards_gallium-pl111 pl111

	# etnaviv/imx drivers
	gallium_enable video_cards_gallium-vivante etnaviv
	gallium_enable video_cards_gallium-imx imx

	# freedreno drivers
	gallium_enable video_cards_gallium-freedreno freedreno
	tool_enable video_cards_gallium-freedreno freedreno

	# SVGA drivers (needed for vmware)
	if use video_cards_gallium-vmware ; then
		gallium_enable gallium-svga
	fi


	# Enable the various platforms
	platform_enable X x11
	platform_enable drm drm
	platform_enable wayland wayland
	platform_enable surfaceless surfaceless
	platform_enable android android
	platform_enable haiku haiku

	# Enable supported arches for OpenSWR based on cpu_flags_x86_*
	for swr_arch in ${ALL_SWR_ARCHES} ; do
		case "${swr_arch}" in
			knl) swr_cpuflag=avx512er ;;
			skx) swr_cpuflag=avx512bw ;;
			*) swr_cpuflag="${swr_arch}"

		esac
		if use cpu_flags_x86_${swr_cpuflag} ; then
			SWR_ARCHES+="${SWR_ARCHES:+,}${swr_arch}"
		fi
	done

	# Setup for alternate install paths
	if use alternate-path ; then
		local my_prefix="${EPREFIX}/usr/$(get_libdir)/${P}"
		local my_libdir="lib"
	else
		local my_prefix="${EPREFIX}/usr"
		local my_libdir="$(get_libdir)"
	fi
	local osmesa_enable
	if use video_cards_osmesa; then
		osmesa_enable="classic"
	elif use video_cards_gallium-osmesa; then
		osmesa_enable="gallium"
	else
		osmesa_enable="none"
	fi
	# Note: egl is "auto" below because it only makes sense if you are building a DRI driver.
	# Let mesa's meson script determine if it is relevant for our case.
	# Many of the other "auto" options below are used in similar way.

	if ! use video_cards_i915 && \
	! use video_cards_i965 && \
	! use video_cards_r100 && \
	! use video_cards_r200 && \
	! use video_cards_nouveau && \
	! use video_cards_swrast; then
		# mesa's meson logic tries to be too smart. We need to detect if we have any DRI cards. If not, 
		# we need to automatically disable some other stuff or meson.build complains. It's always possible
		# that we're asking mesa to build -- but we haven't selected any drivers!
		glx_opt=disabled
		glvnd_opt=false
	else
		glx_opt=auto
		glvnd_opt=true
	fi

	local emesonargs=(
		--prefix="${my_prefix}"
		--libdir="${my_libdir}"
		-Dplatforms=${PLATFORMS}
		-Ddri3=${enable_dri3}
		-Ddri-drivers=${DRI_DRIVERS}
		-Dgallium-drivers=${GALLIUM_DRIVERS}
		-Dgallium-extra-hud=$(usex extra-hud true false)
		-Dgallium-vdpau=$(usex video_cards_vdpau auto false)
		-Dgallium-xvmc=$(usex video_cards_xvmc auto false)
		-Dgallium-omx=$(usex video_cards_openmax bellagio disabled)
		-Dgallium-va=$(usex video_cards_vaapi auto false)
		-Dgallium-xa=$(usex video_cards_xa auto false)
		-Dgallium-nine=$(usex d3d9 true false)
		-Dgallium-opencl=$(usex opencl $(usex ocl-icd icd standalone) disabled)
		-Dvulkan-drivers=${VULKAN_DRIVERS}
		-Dshader-cache=$(usex shader-cache auto false)
		-Dshared-glapi=$(usex opengl true false)
		-Dgles1=$(usex gles1 auto false)
		-Dgles2=$(usex gles2 auto false)
		-Dopengl=$(usex opengl true false)
		-Dgbm=$(usex gbm auto false)
		-Dglx=$(usex glx $glx_opt disabled)
		-Degl=$(usex egl auto false)
		-Dglvnd=$(usex glvnd $glvnd_opt false)
		-Dasm=$(if [[ "${ABI}" == "x86*" ]] ; then echo "false" ; else echo "true"; fi)
		-Dglx-read-only-text=$(if [[ "${ABI}" == "x86" ]] && use pax_kernel ; then echo "true" ; else echo "false"; fi)
		-Dllvm=$(usex llvm true false)
		-Dvalgrind=$(usex valgrind auto false)
		-Dlibunwind=$(usex unwind true false)
		-Dlmsensors=$(usex sensors true false)
		-Dbuild-tests=$(usex test true false)
		-Dselinux=$(usex selinux true false)
		-Dosmesa=$osmesa_enable
		-Dosmesa-bits=8
		-Dswr-arches=${SWR_ARCHES}
		-Dtools=${TOOLS}
		-Dxlib-lease=auto
	)

#	if use llvm ; then
#		export LLVM_CONFIG="$(llvm-config --prefix)/bin/${CHOST}-llvm-config"
#	fi

	use userland_GNU || export INDENT=cat


	# We can't actually use meson_src_configure because it hard-codes the buildtype, prefix, libdir, etc.
	# meson_src_configure

	# Common args -- This is where we need to override:
	local mesonargs=(
			--buildtype $(usex debug debugoptimized release)
			-Db_ndebug=if-release
			--libdir "${my_libdir}"
			--localstatedir "${EPREFIX}/var/lib"
			--sharedstatedir "${EPREFIX}/usr/share/${P}"
			--prefix "${my_prefix}"
			--wrap-mode nodownload
			)

	# https://bugs.gentoo.org/625396
	python_export_utf8_locale

	# Append additional arguments from ebuild
	mesonargs+=("${emesonargs[@]}")

	set -- meson "${EMESON_SOURCE:-${S}}" "${BUILD_DIR}" "${meson_cross[@]}" "${mesonargs[@]}"
	echo "$@"
	tc-env_build "$@" || die
}

src_compile() {
	eninja -C "${BUILD_DIR}"

}

src_install() {
	meson_src_install DESTDIR="${D}"

	if use glvnd ; then 
		find "${ED}/usr/$(get_libdir)/" -name 'libGLESv[12]*.so*' -delete
		mv "${ED}/usr/$(get_libdir)/pkgconfig/gl.pc" "${ED}/usr/$(get_libdir)/pkgconfig/mesa-gl.pc"
		mv "${ED}/usr/$(get_libdir)/pkgconfig/egl.pc" "${ED}/usr/$(get_libdir)/pkgconfig/mesa-egl.pc"
	fi
	find "${ED}" -name '*.la' -delete
	einstalldocs

	# In Funtoo with libglvnd, we rely on media-libs/mesa-gl-headers to install our opengl headers.
	rm -rf ${D}/usr/include || die "can't remove headers"
}

src_test() {
	if use llvm; then
		local llvm_tests='lp_test_arit lp_test_arit lp_test_blend lp_test_blend lp_test_conv lp_test_conv lp_test_format lp_test_format lp_test_printf lp_test_printf'
		pushd src/gallium/drivers/llvmpipe >/dev/null || die
		emake ${llvm_tests}
		pax-mark m ${llvm_tests}
		popd >/dev/null || die
	fi
	emake check
}

pkg_postinst() {

	if use video_cards_openmax; then
		echo "XDG_DATA_DIRS=\"${EPREFIX}/usr/share/${P}/xdg\"" > "${T}/99mesaxdgomx"
		doenvd "${T}"/99mesaxdgomx
		keepdir /usr/share/mesa/xdg
	fi

	# Switch to the xorg implementation.
	#echo
	#eselect opengl set --use-old ${OPENGL_DIR}


	# Switch to mesa opencl
	if use opencl; then
		einfo "Make sure you have the ocl-icd OpenCL dispatcher enabled:"
		einfo "    # eselect opencl set --use-old ocl-icd"
	fi

	# run omxregister-bellagio to make the OpenMAX drivers known system-wide
	if use video_cards_openmax; then
		ebegin "Registering OpenMAX drivers"
		BELLAGIO_SEARCH_PATH="${EPREFIX}/usr/$(get_libdir)/${P}/libomxil-bellagio0" \
			OMX_BELLAGIO_REGISTRY=${EPREFIX}/usr/share/${P}/xdg/.omxregister \
			omxregister-bellagio
		eend $?
	fi
}

pkg_prerm() {
	if use video_cards_openmax; then
		rm "${EPREFIX}"/usr/share/${P}/xdg/.omxregister
	fi
}


# $1 - name of list to add item to
# $2... - list of items to add

_list_add_item() {
	local list_name="$1"
	shift
	while [ $# -gt 0 ] ; do
		local list_val="${!list_name}"
		if ! (IFS=',' has "$1" "${list_val}" ) ; then
			printf -v ${list_name} '%s%s' "${list_val:+${list_val},}" "$1"
		fi
		shift
	done
}

# $1 - name of list to operate on
# $2 - item to enable (if no following args)
# $2 - USE flag to check (if more args follow)
# $3... - list of items to enable if USE flag enabled

_list_enable() {
	local i list
	list="$1"; shift
	case $# in
		0) return 0 ;;
		1) _list_add_item "$list" "$1" ;;
		*) if use "$1" ; then shift ; for i in "$@"; do _list_add_item "$list" "$i" ; done ; fi ;;
	esac
}

dri_enable() {
	_list_enable "DRI_DRIVERS" "$@"
}

gallium_enable() {
	_list_enable "GALLIUM_DRIVERS" "$@"
}

vulkan_enable() {
	_list_enable "VULKAN_DRIVERS" "$@"
}

platform_enable() {
	_list_enable "PLATFORMS" "$@"
}

tool_enable() {
	_list_enable "TOOLS" "$@"
}
