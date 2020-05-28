# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

ETYPE="sources"
K_WANT_GENPATCHES="base extras experimental"
K_GENPATCHES_VER="18"
UNIPATCH_STRICTORDER=1

inherit kernel-2 eutils readme.gentoo-r1

detect_version
detect_arch

AUFS_VERSION="5.6-20200518"
COMMIT="2f277f23484fbe2dbc2378c3dc96b48d49b2a2cd"
AUFS_URI="https://github.com/sfjro/aufs5-standalone/archive/${COMMIT}.tar.gz -> aufs-${AUFS_VERSION}.tar.gz"
AUFS_TARBALL="aufs-${AUFS_VERSION}.tar.gz"

KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sparc ~x86"
HOMEPAGE="https://dev.gentoo.org/~mpagano/genpatches"
IUSE="+aufs experimental"

DESCRIPTION="Full sources including the Gentoo patchset for the ${KV_MAJOR}.${KV_MINOR} kernel tree and aufs5 support"

STANDALONE="${WORKDIR}/aufs5-standalone-${COMMIT}"

SRC_URI="
	${KERNEL_URI}
	${ARCH_URI}
	${GENPATCHES_URI}
	aufs? ( ${AUFS_URI} )
	"

PDEPEND="
	=sys-fs/aufs-util-4*
	"
README_GENTOO_SUFFIX="-r1"

src_unpack() {
	if use aufs; then
		detect_version
		detect_arch
		UNIPATCH_LIST="
			"${STANDALONE}"/aufs5-kbuild.patch
			"${STANDALONE}"/aufs5-base.patch
			"${STANDALONE}"/aufs5-mmap.patch"

		unpack ${AUFS_TARBALL}
		einfo "Using aufs5 version: ${AUFS_VERSION}"
		kernel-2_src_unpack
	fi
}

src_prepare() {
	if use aufs; then
		kernel-2_src_prepare
		sed -e 's:tristate:bool:g' -i "${STANDALONE}"/fs/aufs/Kconfig || die
		cp -f "${STANDALONE}"/include/uapi/linux/aufs_type.h include/uapi/linux/aufs_type.h || die
		cp -rf "${STANDALONE}"/{Documentation,fs} . || die
	fi
}

src_install() {
	if use aufs; then
		kernel-2_src_install
		dodoc "${STANDALONE}"/{aufs5-loopback,vfs-ino,tmpfs-idr}.patch
		docompress -x /usr/share/doc/${PF}/{aufs5-loopback,vfs-ino,tmpfs-idr}.patch
		readme.gentoo_create_doc
	fi
}

pkg_postinst() {
	kernel-2_pkg_postinst
	einfo "For more info on this patchset, and how to report problems, see:"
	einfo "${HOMEPAGE}"
	if use aufs; then
		has_version sys-fs/aufs-util || \
			elog "In order to use aufs FS you need to install sys-fs/aufs-util"

		readme.gentoo_print_elog

	fi
}

pkg_postrm() {
	kernel-2_pkg_postrm
}
