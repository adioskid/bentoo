# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CMAKE_REMOVE_MODULES_LIST=( FindFreetype )
LUA_COMPAT=( luajit )
PYTHON_COMPAT=( python3_{7..9} )

inherit cmake lua-single python-single-r1 xdg-utils

SRC_URI="
	https://api.github.com/repos/obsproject/obs-studio/tarball/${PV} -> obs-studio-${P}.tar.gz
	browser? ( https://github.com/obsproject/obs-browser/archive/f1a61c5a2579e5673765c31a47c2053d4b502d4b.tar.gz https://cdn-fastly.obsproject.com/downloads/cef_binary_4280_linux64.tar.bz2 )
"
KEYWORDS="*"

DESCRIPTION="Software for Recording and Streaming Live Video Content"
HOMEPAGE="https://obsproject.com"

LICENSE="GPL-2"
SLOT="0"
IUSE="+alsa browser fdk imagemagick jack lua nvenc pipewire pulseaudio python speex +ssl truetype v4l vlc"
REQUIRED_USE="
	lua? ( ${LUA_REQUIRED_USE} )
	python? ( ${PYTHON_REQUIRED_USE} )
"

BDEPEND="
	lua? ( dev-lang/swig )
	python? ( dev-lang/swig )
"
DEPEND="
	>=dev-libs/jansson-2.5
	dev-qt/qtcore:5
	dev-qt/qtdeclarative:5
	dev-qt/qtgui:5
	dev-qt/qtmultimedia:5
	dev-qt/qtnetwork:5
	dev-qt/qtquickcontrols:5
	dev-qt/qtsql:5
	dev-qt/qtsvg:5
	dev-qt/qtwidgets:5
	dev-qt/qtx11extras:5
	dev-qt/qtxml:5
	media-libs/x264:=
	media-video/ffmpeg:=[x264]
	net-misc/curl
	sys-apps/dbus
	sys-libs/zlib
	virtual/udev
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXfixes
	x11-libs/libXinerama
	x11-libs/libXrandr
	x11-libs/libxcb
	alsa? ( media-libs/alsa-lib )
	browser? (
		app-accessibility/at-spi2-atk
		dev-libs/atk
		dev-libs/expat
		dev-libs/glib
		dev-libs/nspr
		dev-libs/nss
		media-libs/fontconfig
		x11-libs/libXcursor
		x11-libs/libXdamage
		x11-libs/libXext
		x11-libs/libXi
		x11-libs/libXrender
		x11-libs/libXScrnSaver
		x11-libs/libXtst
	)
	fdk? ( media-libs/fdk-aac:= )
	imagemagick? ( media-gfx/imagemagick:= )
	jack? ( virtual/jack )
	lua? ( ${LUA_DEPS} )
	nvenc? ( >=media-video/ffmpeg-4[video_cards_nvidia] )
	pipewire? ( media-video/pipewire )
	pulseaudio? ( media-sound/pulseaudio )
	python? ( ${PYTHON_DEPS} )
	speex? ( media-libs/speexdsp )
	ssl? ( net-libs/mbedtls:= )
	truetype? (
		media-libs/fontconfig
		media-libs/freetype
	)
	v4l? ( media-libs/libv4l )
	vlc? ( media-video/vlc:= )
"
RDEPEND="${DEPEND}"

src_unpack() {
	default
	mv ${WORKDIR}/obsproject-obs-studio-??????? ${P} || die
	if use browser; then
		rm -d "${P}/plugins/obs-browser" || die
		mv ${WORKDIR}/obs-browser-* ${P}/plugins/obs-browser || die
	fi
}

pkg_setup() {
	use lua && lua-single_pkg_setup
	use python && python-single-r1_pkg_setup
}

src_configure() {
	local libdir=$(get_libdir)
	local mycmakeargs=(
		-DDISABLE_ALSA=$(usex !alsa)
		-DBUILD_BROWSER=$(usex browser)
		-DDISABLE_FREETYPE=$(usex !truetype)
		-DDISABLE_JACK=$(usex !jack)
		-DDISABLE_LIBFDK=$(usex !fdk)
		-DENABLE_PIPEWIRE=$(usex pipewire)
		-DDISABLE_PULSEAUDIO=$(usex !pulseaudio)
		-DDISABLE_SPEEXDSP=$(usex !speex)
		-DDISABLE_V4L2=$(usex !v4l)
		-DDISABLE_VLC=$(usex !vlc)
		-DLIBOBS_PREFER_IMAGEMAGICK=$(usex imagemagick)
		-DOBS_MULTIARCH_SUFFIX=${libdir#lib}
		-DUNIX_STRUCTURE=1
		-DWITH_RTMPS=$(usex ssl)
		-DOBS_VERSION_OVERRIDE=${PV}
		# FIXME: No info about this in the install instructions?
		-DBUILD_VST=OFF
	)

	if use browser; then
		mycmakeargs+=(
			-DCEF_ROOT_DIR="../cef_binary_4280_linux64"
		)
	fi

	if use lua || use python; then
		mycmakeargs+=(
			-DDISABLE_LUA=$(usex !lua)
			-DDISABLE_PYTHON=$(usex !python)
			-DENABLE_SCRIPTING=yes
		)
	else
		mycmakeargs+=( -DENABLE_SCRIPTING=no )
	fi

	cmake_src_configure
}

src_install() {
	cmake_src_install
	#external plugins may need some things not installed by default, install them here
	insinto /usr/include/obs/UI/obs-frontend-api
	doins UI/obs-frontend-api/obs-frontend-api.h
}

pkg_postinst() {
	xdg_icon_cache_update

	if ! use alsa && ! use pulseaudio; then
		elog
		elog "For the audio capture features to be available,"
		elog "either the 'alsa' or the 'pulseaudio' USE-flag needs to"
		elog "be enabled."
		elog
	fi

	if ! has_version "sys-apps/dbus"; then
		elog
		elog "The 'sys-apps/dbus' package is not installed, but"
		elog "could be used for disabling hibernating, screensaving,"
		elog "and sleeping.  Where it is not installed,"
		elog "'xdg-screensaver reset' is used instead"
		elog "(if 'x11-misc/xdg-utils' is installed)."
		elog
	fi
}

pkg_postinst() {
	if use python; then
		ewarn "This ebuild applies a patch that is not yet accepted upstream,"
		ewarn "and while it fixes Python support at least to some extent, it"
		ewarn "may cause other issues."
		ewarn ""
		ewarn "Please report any such issues to the Gentoo maintainer."
	fi
}

pkg_postrm() {
	xdg_icon_cache_update
}
