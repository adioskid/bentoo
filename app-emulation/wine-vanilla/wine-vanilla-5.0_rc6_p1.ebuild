# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# shellcheck disable=SC2034
EAPI=7

PLOCALES="ar ast bg ca cs da de el en en_US eo es fa fi fr he hi hr hu it ja ko lt ml nb_NO nl or pa pl pt_BR pt_PT rm ro ru si sk sl sr_RS@cyrillic sr_RS@latin sv ta te th tr uk wa zh_CN zh_TW"
PLOCALE_BACKUP="en"

inherit autotools flag-o-matic l10n multilib multilib-minimal pax-utils toolchain-funcs virtualx wine xdg-utils-r1

if [[ "${WINE_PV}" == "9999" ]]; then
	EGIT_REPO_URI="https://source.winehq.org/git/wine.git"
	inherit git-r3
else
	KEYWORDS="-* ~amd64 ~x86"
fi

DESCRIPTION="Free implementation of Windows(tm) on Unix, without any external patchsets"
HOMEPAGE="https://www.winehq.org/"
SRC_URI="${SRC_URI}
	esync? (
		https://github.com/bobwya/${WINE_ESYNC_PN}/archive/${WINE_ESYNC_PV}.tar.gz -> ${WINE_ESYNC_P}.tar.gz
	)"

LICENSE="LGPL-2.1"
SLOT="${PV}"

IUSE="+abi_x86_32 +abi_x86_64 +alsa capi cups custom-cflags dos elibc_glibc esync faudio +fontconfig +gecko gphoto2 gsm gstreamer +jpeg kerberos kernel_FreeBSD +lcms ldap +mono mp3 ncurses netapi nls odbc openal opencl +opengl osmesa oss pcap +perl +png prelink prefix pulseaudio +realtime +run-exes samba scanner sdl2 selinux +ssl test +threads +truetype udev +udisks v4l vkd3d vulkan +X +xcomposite xinerama +xml"
REQUIRED_USE="|| ( abi_x86_32 abi_x86_64 )
	X? ( truetype )
	elibc_glibc? ( threads )
	osmesa? ( opengl )
	test? ( abi_x86_32 )
	vkd3d? ( vulkan )" #286560 osmesa-opengl  #551124 X-truetype

# FIXME: the test suite is unsuitable for us; many tests require net access
# or fail due to Xvfb's opengl limitations.
RESTRICT="test"

COMMON_DEPEND="
	>=app-emulation/wine-desktop-common-20180412
	X? (
		x11-libs/libXcursor[${MULTILIB_USEDEP}]
		x11-libs/libXext[${MULTILIB_USEDEP}]
		x11-libs/libXfixes[${MULTILIB_USEDEP}]
		x11-libs/libXrandr[${MULTILIB_USEDEP}]
		x11-libs/libXi[${MULTILIB_USEDEP}]
		x11-libs/libXxf86vm[${MULTILIB_USEDEP}]
	)
	alsa? ( media-libs/alsa-lib[${MULTILIB_USEDEP}] )
	capi? ( net-libs/libcapi[${MULTILIB_USEDEP}] )
	cups? ( net-print/cups:=[${MULTILIB_USEDEP}] )
	faudio? ( app-emulation/faudio[${MULTILIB_USEDEP}] )
	fontconfig? ( media-libs/fontconfig:=[${MULTILIB_USEDEP}] )
	gphoto2? ( media-libs/libgphoto2:=[${MULTILIB_USEDEP}] )
	gsm? ( media-sound/gsm:=[${MULTILIB_USEDEP}] )
	gstreamer? (
		media-libs/gstreamer:1.0[${MULTILIB_USEDEP}]
		media-plugins/gst-plugins-meta:1.0[${MULTILIB_USEDEP}]
	)
	jpeg? ( virtual/jpeg:0=[${MULTILIB_USEDEP}] )
	kerberos? ( virtual/krb5:0=[${MULTILIB_USEDEP}] )
	lcms? ( media-libs/lcms:2=[${MULTILIB_USEDEP}] )
	ldap? ( net-nds/openldap:=[${MULTILIB_USEDEP}] )
	mp3? ( >=media-sound/mpg123-1.5.0[${MULTILIB_USEDEP}] )
	ncurses? ( >=sys-libs/ncurses-5.2:0=[${MULTILIB_USEDEP}] )
	netapi? ( net-fs/samba[netapi(+),${MULTILIB_USEDEP}] )
	nls? ( sys-devel/gettext[${MULTILIB_USEDEP}] )
	odbc? ( dev-db/unixODBC:=[${MULTILIB_USEDEP}] )
	openal? ( media-libs/openal:=[${MULTILIB_USEDEP}] )
	opencl? ( virtual/opencl[${MULTILIB_USEDEP}] )
	opengl? (
		virtual/glu[${MULTILIB_USEDEP}]
		virtual/opengl[${MULTILIB_USEDEP}]
	)
	osmesa? ( >=media-libs/mesa-13[osmesa,${MULTILIB_USEDEP}] )
	pcap? ( net-libs/libpcap[${MULTILIB_USEDEP}] )
	png? ( media-libs/libpng:0=[${MULTILIB_USEDEP}] )
	pulseaudio? ( media-sound/pulseaudio[${MULTILIB_USEDEP}] )
	scanner? ( media-gfx/sane-backends:=[${MULTILIB_USEDEP}] )
	sdl2? ( media-libs/libsdl2[haptic,joystick,${MULTILIB_USEDEP}] )
	ssl? ( net-libs/gnutls:=[${MULTILIB_USEDEP}] )
	truetype? ( >=media-libs/freetype-2.0.5[${MULTILIB_USEDEP}] )
	udev? ( virtual/libudev:=[${MULTILIB_USEDEP}] )
	udisks? ( sys-apps/dbus[${MULTILIB_USEDEP}] )
	vkd3d? ( >=app-emulation/vkd3d-1.1[${MULTILIB_USEDEP}] )
	v4l? ( media-libs/libv4l[${MULTILIB_USEDEP}] )
	vulkan? ( media-libs/vulkan-loader[X,${MULTILIB_USEDEP}] )
	xcomposite? ( x11-libs/libXcomposite[${MULTILIB_USEDEP}] )
	xinerama? ( x11-libs/libXinerama[${MULTILIB_USEDEP}] )
	xml? (
		dev-libs/libxml2[${MULTILIB_USEDEP}]
		dev-libs/libxslt[${MULTILIB_USEDEP}]
	)
"

RDEPEND="${COMMON_DEPEND}
	!app-emulation/wine:0
	>=app-eselect/eselect-wine-1.5.5
	dos? ( >=games-emulation/dosbox-0.74_p20160629 )
	gecko? ( app-emulation/wine-gecko:2.47.1[abi_x86_32?,abi_x86_64?] )
	mono? ( app-emulation/wine-mono:4.9.4 )
	perl? (
		dev-lang/perl
		dev-perl/XML-Simple
	)
	pulseaudio? (
		realtime? ( sys-auth/rtkit )
	)
	samba? ( >=net-fs/samba-3.0.25[winbind] )
	selinux? ( sec-policy/selinux-wine )
	udisks? ( sys-fs/udisks:2 )
"

# tools/make_requests requires perl
DEPEND="${COMMON_DEPEND}
	dev-util/patchbin
	dev-lang/perl
	dev-perl/XML-Simple
	>=sys-devel/flex-2.5.33
	>=sys-kernel/linux-headers-2.6
	virtual/pkgconfig
	virtual/yacc
	X? ( x11-base/xorg-proto )
	prelink? ( sys-devel/prelink )
	xinerama? ( x11-base/xorg-proto )"

S="${WORKDIR}/${WINE_P}"
src_unpack() {
	# Fully Mirror git tree, Wine, so we can access commits in all branches
	[[ "${WINE_PV}" == "9999" ]] && EGIT_MIN_CLONE_TYPE="mirror"

	default

	l10n_find_plocales_changes "${S}/po" "" ".po"
}

src_prepare() {
	local md5hash
	md5hash="$(md5sum server/protocol.def)" || die "md5sum failed"
	[[ -n "${WINE_STABLE_PREFIX}" ]] && sed -i -e 's/[-.[:alnum:]]\+$/'"${WINE_PV}"'/' "${S}/VERSION"
	local -a PATCHES PATCHES_BIN

	wine_add_stock_gentoo_patches

	wine_fix_gentoo_cc_multilib_support
	wine_fix_gentoo_O3_compilation_support
	wine_fix_gentoo_winegcc_support
	wine_support_wine_mono_downgrade

	use esync && wine_eapply_esync_patchset "${WORKDIR}/${WINE_ESYNC_P}"

	#617864 Generate wine64 man pages for 64-bit bit only installation
	if use abi_x86_64 && ! use abi_x86_32; then
		wine_src_force_64bit_manpages
	fi

	#469418 Respect LINGUAS/L10N when building man pages
	wine_src_disable_unused_locale_man_files

	# Don't build winedump,winemaker if not using perl
	use perl || wine_src_disable_specfied_tools winedump winemaker

	#551124 Only build wineconsole, if either of X or ncurses is installed
	use X || use ncurses || wine_src_prepare_disable_tools wineconsole

	default

	wine_eapply_bin

	eautoreconf

	# Modification of the server protocol requires regenerating the server requests
	if ! md5sum -c - <<<"${md5hash}" >/dev/null 2>&1; then
		einfo "server/protocol.def was patched; running tools/make_requests"
		tools/make_requests || die "tools/make_requests failed" #432348
	fi
	sed -i '/^UPDATE_DESKTOP_DATABASE/s:=.*:=true:' tools/Makefile.in || die "sed failed"
	if use run-exes; then
		sed -i '\:^Exec=:{s:wine :wine-'"${WINE_VARIANT}"' :}' "${S}/loader/wine.desktop" || die "sed failed"
	else
		sed -i '/^MimeType/d' "${S}/loader/wine.desktop" || die "sed failed" #117785
	fi

	#472990 use hi-res default icon, https://bugs.winehq.org/show_bug.cgi?id=24652
	cp "${EROOT%/}/usr/share/wine/icons/oic_winlogo.ico" dlls/user32/resources/ || die "cp failed"

	l10n_get_locales > "${S}/po/LINGUAS" || die "l10n_get_locales failed" # Make Wine respect LINGUAS
}

multilib_src_configure() {
	local myconf=(
		"--prefix=${WINE_PREFIX}"
		"--datarootdir=${WINE_DATAROOTDIR}"
		"--datadir=${WINE_DATADIR}"
		"--docdir=${WINE_DOCDIR}"
		"--includedir=${WINE_INCLUDEDIR}"
		"--libdir=${EPREFIX}/usr/$(get_libdir)/wine-${WINE_VARIANT}"
		"--libexecdir=${WINE_LIBEXECDIR}"
		"--localstatedir=${WINE_LOCALSTATEDIR}"
		"--mandir=${WINE_MANDIR}"
		"--sysconfdir=/etc/wine"
		"$(use_with alsa)"
		"$(use_with capi)"
		"$(use_with lcms cms)"
		"$(use_with cups)"
		"$(use_with ncurses curses)"
		"$(use_with faudio)"
		"$(use_with fontconfig)"
		"$(use_with ssl gnutls)"
		"$(use_enable gecko mshtml)"
		"$(use_with gphoto2 gphoto)"
		"$(use_with gsm)"
		"$(use_with gstreamer)"
		--without-hal
		"$(use_with jpeg)"
		"$(use_with kerberos gssapi)"
		"$(use_with kerberos krb5)"
		"$(use_with ldap)"
		"$(use_enable mono mscoree)"
		"$(use_with mp3 mpg123)"
		"$(use_with netapi)"
		"$(use_with nls gettext)"
		"$(use_with openal)"
		"$(use_with opencl)"
		"$(use_with opengl)"
		"$(use_with osmesa)"
		"$(use_with oss)"
		"$(use_with pcap)"
		"$(use_with png)"
		"$(use_with pulseaudio pulse)"
		"$(use_with threads pthread)"
		"$(use_with scanner sane)"
		"$(use_with sdl2 sdl)"
		"$(use_enable test tests)"
		"$(use_with truetype freetype)"
		"$(use_with udev)"
		"$(use_with udisks dbus)"
		"$(use_with v4l v4l2)"
		"$(use_with vkd3d)"
		"$(use_with vulkan)"
		"$(use_with X x)"
		"$(use_with X xfixes)"
		"$(use_with xcomposite)"
		"$(use_with xinerama)"
		"$(use_with xml)"
		"$(use_with xml xslt)"
	)

	local PKG_CONFIG AR RANLIB
	#472038 Avoid crossdev's i686-pc-linux-gnu-pkg-config if building wine32 on amd64
	#483342 set AR and RANLIB to make QA scripts happy
	tc-export PKG_CONFIG AR RANLIB

	if use amd64; then
		if [[ "${ABI}" == "amd64" ]]; then
			myconf+=( --enable-win64 )
		else
			myconf+=( --disable-win64 )
		fi

		# Note: using --with-wine64 results in problems with multilib.eclass
		# CC/LD hackery. We're using separate tools instead.
	fi

	ECONF_SOURCE=${S} \
		econf "${myconf[@]}"
	emake depend
}

multilib_src_install_all() {
	DOCS=( "ANNOUNCE" "AUTHORS" "README" )
	l10n_for_each_locale_do wine_add_locale_docs

	einstalldocs
	unset -v DOCS

	find "${D}" -name '*.la' -delete || die "find failed"

	use abi_x86_32 && pax-mark psmr "${D%/}${WINE_PREFIX}/bin/wine"{,-preloader}   #255055
	use abi_x86_64 && pax-mark psmr "${D%/}${WINE_PREFIX}/bin/wine64"{,-preloader} #255055

	if use abi_x86_64 && ! use abi_x86_32; then
		local wine64_binary
		for wine64_binary in "wine64" "wine64-preloader"; do
			dosym "${wine64_binary}" "${WINE_PREFIX}/bin/${wine64_binary/wine64/wine}"
		done
		wine_symlink_64bit_manpages
	fi

	wine_make_variant_wrappers
}
