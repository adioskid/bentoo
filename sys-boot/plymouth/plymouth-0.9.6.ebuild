# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGIT_COMMIT="e3a2cb956665e5e30da50ad9357fcc6e9d9a6398"
SRC_URI="
	https://github.com/freedesktop/plymouth/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz
	http://distfiles.gentoo.org/distfiles/be/gentoo-logo.png"

KEYWORDS="~alpha amd64 arm arm64 ~ia64 ppc ppc64 sparc x86"

S="${WORKDIR}/${PN}-${EGIT_COMMIT}"

inherit autotools readme.gentoo-r1 systemd toolchain-funcs

DESCRIPTION="Graphical boot animation (splash) and logger"
HOMEPAGE="https://cgit.freedesktop.org/plymouth/"

LICENSE="GPL-2"
SLOT="0"
IUSE="debug +gtk +libkms +pango +split-usr static-libs +udev"

CDEPEND="
	>=media-libs/libpng-1.2.16:=
	gtk? (
		dev-libs/glib:2
		>=x11-libs/gtk+-3.14:3
		x11-libs/cairo
	)
	libkms? ( x11-libs/libdrm[libkms] )
	pango? ( >=x11-libs/pango-1.21 )
"
DEPEND="${CDEPEND}
	elibc_musl? ( sys-libs/rpmatch-standalone )
	app-text/docbook-xsl-stylesheets
	dev-libs/libxslt
	virtual/pkgconfig
"
# Block due bug #383067
RDEPEND="${CDEPEND}
	udev? ( virtual/udev )
	!<sys-kernel/dracut-0.37-r3
"

DOC_CONTENTS="
	Follow the following instructions to set up Plymouth:\n
	https://wiki.gentoo.org/wiki/Plymouth#Configuration
"

PATCHES=(
	"${FILESDIR}"/0.9.3-glibc-sysmacros.patch
)

src_prepare() {
	use elibc_musl && append-ldflags -lrpmatch
	default
	eautoreconf
}

src_configure() {
	local myconf=(
		--with-system-root-install=no
		--localstatedir=/var
		--without-rhgb-compat-link
		--enable-documentation
		--enable-systemd-integration
		--with-systemdunitdir="$(systemd_get_systemunitdir)"
		$(use_enable !static-libs shared)
		$(use_enable static-libs static)
		$(use_enable debug tracing)
		$(use_enable gtk gtk)
		$(use_enable libkms drm)
		$(use_enable pango)
		$(use_with udev)
	)
	econf "${myconf[@]}"
}

src_install() {
	default

	insinto /usr/share/plymouth
	newins "${DISTDIR}"/gentoo-logo.png bizcom.png

	if use split-usr ; then
		# Install compatibility symlinks as some rdeps hardcode the paths
		dosym ../usr/bin/plymouth /bin/plymouth
		dosym ../usr/sbin/plymouth-set-default-theme /sbin/plymouth-set-default-theme
		dosym ../usr/sbin/plymouthd /sbin/plymouthd
	fi

	readme.gentoo_create_doc

	# looks like make install create /var/run/plymouth
	# this is not needed for systemd, same should hold for openrc
	# so remove
	rm -rf "${D}"/var/run

	# fix broken symlink
	dosym ../../bizcom.png /usr/share/plymouth/themes/spinfinity/header-image.png
}

pkg_postinst() {
	readme.gentoo_print_elog
	if ! has_version "sys-kernel/dracut" && ! has_version "sys-kernel/genkernel-next[plymouth]"; then
		ewarn "If you want initramfs builder with plymouth support, please emerge"
		ewarn "sys-kernel/dracut or sys-kernel/genkernel-next[plymouth]."
	fi
}
