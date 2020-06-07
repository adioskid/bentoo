# Distributed under the terms of the GNU General Public License v2

EAPI=6
CMAKE_MAKEFILE_GENERATOR="ninja"
PYTHON_COMPAT=( python2_7 )
USE_RUBY="ruby24 ruby25 ruby26"
CMAKE_MIN_VERSION=3.10

inherit check-reqs cmake-utils flag-o-matic gnome2 pax-utils python-any-r1 ruby-single toolchain-funcs virtualx

DESCRIPTION="Open source web browser engine"
HOMEPAGE="https://www.webkit.org"

GITHUB_REPO="webkit"
GITHUB_USER="funtoo"
GITHUB_TAG="1c0fa7838f79e444a62e62da747fd81c16e6e97e"
SRC_URI="https://www.github.com/${GITHUB_USER}/${GITHUB_REPO}/tarball/${GITHUB_TAG} -> ${P}-${GITHUB_TAG}.tar.gz"

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}/${GITHUB_USER}-${GITHUB_REPO}"-??????? "${S}" || die
}

LICENSE="LGPL-2+ BSD"
SLOT="4/37" # soname version of libwebkit2gtk-4.0
KEYWORDS="*"

IUSE="debug +introspection wayland +X"

# "strip" is needed in RESTRICT for debugging...
RESTRICT="test userpriv"

# !<=net-libs/webkit-gtk-2.26.3:
# blocker to remove older webkit-gtk that contains files this ebuild installs now.
RDEPEND="
	!<=net-libs/webkit-gtk-2.26.3
	>=x11-libs/cairo-1.16.0:=[X?]
	>=media-libs/fontconfig-2.13.0:1.0
	>=media-libs/freetype-2.9.0:2
	>=dev-libs/libgcrypt-1.7.0:0=
	media-sound/pulseaudio
	>=x11-libs/gtk+-3.22:3[introspection,wayland?,X?]
	>=media-libs/harfbuzz-1.4.2:=[icu(+)]
	>=dev-libs/icu-3.8.1-r1:=
	virtual/jpeg:0=
	>=net-libs/libsoup-2.48:2.4[introspection]
	>=dev-libs/libxml2-2.8.0:2
	>=media-libs/libpng-1.4:0=
	dev-db/sqlite:3=
	sys-libs/zlib:0
	>=dev-libs/atk-2.8.0
	media-libs/libwebp:=

	dev-libs/libevent
	>=dev-libs/glib-2.40:2
	>=dev-libs/libxslt-1.1.7
	media-libs/woff2
	>=sys-apps/bubblewrap-0.3.1:0
	app-crypt/libsecret
	>=app-misc/geoclue-2.1.5:2.0
	>=dev-libs/gobject-introspection-1.32.0:=
	dev-libs/libtasn1:=
	>=app-text/enchant-0.22:=
	>=media-libs/gstreamer-1.14:1.0
	>=media-libs/gst-plugins-base-1.14:1.0[opengl]
	>=media-plugins/gst-plugins-opus-1.14.4-r1:1.0
	>=media-libs/gst-plugins-bad-1.14:1.0

	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXrender
	x11-libs/libXt

	x11-libs/libnotify
	dev-libs/hyphen
	>=media-libs/openjpeg-2.2.0:2=

	virtual/opengl
	x11-libs/libXcomposite
	x11-libs/libXdamage

	wayland? (
		gui-libs/wpebackend-fdo
	)

"

# paxctl needed for bug #407085
# Need real bison, not yacc
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	${RUBY_DEPS}
	dev-util/xdg-dbus-proxy
	>=app-accessibility/at-spi2-core-2.5.3
	dev-util/glib-utils
	>=dev-util/gtk-doc-am-1.10
	>=dev-util/gperf-3.0.1
	>=sys-devel/bison-2.4.3
	|| ( >=sys-devel/gcc-6.0 >=sys-devel/clang-3.3 )
	sys-devel/gettext
	virtual/pkgconfig

	>=dev-lang/perl-5.10
	virtual/perl-Data-Dumper
	virtual/perl-Carp
	virtual/perl-JSON-PP

	>=dev-util/gtk-doc-1.10
	dev-util/gdbus-codegen
"

CHECKREQS_DISK_BUILD="18G" # and even this might not be enough, bug #417307

pkg_pretend() {
	if [[ ${MERGE_TYPE} != "binary" ]] ; then
		if is-flagq "-g*" && ! is-flagq "-g*0" ; then
			einfo "Checking for sufficient disk space to build ${PN} with debugging CFLAGS"
			check-reqs_pkg_pretend
		fi

		if ! test-flag-CXX -std=c++11 ; then
			die "You need at least GCC 4.9.x or Clang >= 3.3 for C++11-specific compiler flags"
		fi

		if tc-is-gcc && [[ $(gcc-version) < 4.9 ]] ; then
			die 'The active compiler needs to be gcc 4.9 (or newer)'
		fi
	fi
}

pkg_setup() {
	if use debug; then
		export CFLAGS="$CFLAGS -g3"
		export CXXFLAGS="$CXXFLAGS -g3"
	fi
	if [[ ${MERGE_TYPE} != "binary" ]] && is-flagq "-g*" && ! is-flagq "-g*0" ; then
		check-reqs_pkg_setup
	fi
	python-any-r1_pkg_setup
}

src_prepare() {
	cmake-utils_src_prepare
}

src_configure() {
	return
}

src_compile() {
	# see https://www.mail-archive.com/webkit-dev@lists.webkit.org/msg29308.html

	# Ruby situation is a bit complicated. See bug 513888
	local rubyimpl
	local ruby_interpreter=""
	for rubyimpl in ${USE_RUBY}; do
		if has_version "virtual/rubygems[ruby_targets_${rubyimpl}]"; then
			ruby_interpreter="-DRUBY_EXECUTABLE=$(type -P ${rubyimpl})"
		fi
	done
	# This will rarely occur. Only a couple of corner cases could lead us to
	# that failure. See bug 513888
	[[ -z $ruby_interpreter ]] && die "No suitable ruby interpreter found"

	local mycmakeargs=(
		${ruby_interpreter}
		-DENABLE_INTROSPECTION=$(usex introspection)
		-DENABLE_X11_TARGET=$(usex X)
		-DENABLE_WAYLAND_TARGET=$(usex wayland)
	)
	${S}/Tools/Scripts/set-webkit-configuration --force-optimization-level=none || die
	if use debug; then
		${S}/Tools/Scripts/build-webkit --gtk --debug --prefix=/usr --only-webkit --makeargs="${MAKEOPTS}" --cmakeargs="${mycmakeargs[*]}" || die
	else
		${S}/Tools/Scripts/build-webkit --gtk --release --prefix=/usr --only-webkit --makeargs="${MAKEOPTS}" --cmakeargs="${mycmakeargs[*]}" || die
	fi
}

#src_test() {
#	# Prevents test failures on PaX systems
#	pax-mark m $(list-paxables Programs/*[Tt]ests/*) # Programs/unittests/.libs/test*
#	cmake-utils_src_test
#}

src_install() {
	if use debug; then
		( cd ${S}/WebKitBuild/Debug && DESTDIR="${D}" ninja install ) || die "install"
	else
		( cd ${S}/WebKitBuild/Release && DESTDIR="${D}" ninja install ) || die "install"
	fi
	einstalldocs
	# Prevents crashes on PaX systems, bug #522808
	pax-mark m "${ED}usr/libexec/webkit2gtk-4.0/jsc" "${ED}usr/libexec/webkit2gtk-4.0/WebKitWebProcess"
	pax-mark m "${ED}usr/libexec/webkit2gtk-4.0/WebKitPluginProcess"
}
