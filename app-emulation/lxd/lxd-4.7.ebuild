# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools bash-completion-r1 linux-info user

DESCRIPTION="Fast, dense and secure container management"
HOMEPAGE="https://linuxcontainers.org/lxd/introduction/ https://github.com/lxc/lxd"
SRC_URI="https://linuxcontainers.org/downloads/${PN}/${P}.tar.gz"

# Needs to include licenses for all bundled programs and libraries.
LICENSE="Apache-2.0 BSD BSD-2 LGPL-3 MIT MPL-2.0"
SLOT="0"
KEYWORDS=""
IUSE="apparmor +ipv6 nls"

DEPEND="app-arch/xz-utils
	>=app-emulation/lxc-3.0.0[apparmor?,seccomp]
	>=sys-kernel/linux-headers-4.15
	dev-lang/tcl
	dev-libs/libuv
	dev-libs/lzo
	net-dns/dnsmasq[dhcp,ipv6?]"
RDEPEND="${DEPEND}
	net-firewall/ebtables
	net-firewall/iptables[ipv6?]
	sys-apps/iproute2[ipv6?]
	sys-fs/fuse:0=
	sys-fs/lxcfs
	sys-fs/squashfs-tools
	virtual/acl"
BDEPEND=">=dev-lang/go-1.13
	nls? ( sys-devel/gettext )"

CONFIG_CHECK="
	~BRIDGE
	~DUMMY
	~IP6_NF_NAT
	~IP6_NF_TARGET_MASQUERADE
	~IPV6
	~IP_NF_NAT
	~IP_NF_TARGET_MASQUERADE
	~MACVLAN
	~NETFILTER_XT_MATCH_COMMENT
	~NET_IPGRE
	~NET_IPGRE_DEMUX
	~NET_IPIP
	~NF_NAT_MASQUERADE
	~VSOCKETS
	~VXLAN
"

# 4.0.3: Network fetching fixed, but tests don't work when ran inside container.
RESTRICT="test"

# Go magic.
QA_PREBUILT="/usr/lib/lxd/libdqlite.so.0.0.1
	/usr/bin/fuidshift
	/usr/bin/lxc
	/usr/bin/lxc-to-lxd
	/usr/bin/lxd-agent
	/usr/bin/lxd-benchmark
	/usr/bin/lxd-p2c
	/usr/sbin/lxd"

EGO_PN="github.com/lxc/lxd"
GOPATH="${S}/_dist" # this seems to reset every now and then, though

common_op() {
	local i
	for i in dqlite raft; do
		cd "${GOPATH}"/deps/${i} || die "failed to switch dir to ${i}"
		"${@}"
		cd "${S}" || die "failed to switch dir back from ${i} to ${S}"
	done
}

src_prepare() {
	default

	export GOPATH="${S}/_dist"

	sed -i \
		-e "s:\./configure:./configure --prefix=/usr --libdir=${EPREFIX}/usr/lib/lxd:g" \
		-e "s:make:make ${MAKEOPTS}:g" \
		Makefile || die

	sed -i 's#zfs version 2>/dev/null | cut -f 2 -d - | head -1#< /sys/module/zfs/version cut -f 1#' "${GOPATH}"/deps/raft/configure.ac || die

	common_op eautoreconf
}

src_configure() {
	export GOPATH="${S}/_dist"

	export RAFT_CFLAGS="-I${GOPATH}/deps/raft/include/"
	export RAFT_LIBS="${GOPATH}/deps/raft/.libs"

	export PKG_CONFIG_PATH="${GOPATH}/raft/"

	common_op econf --libdir="${EPREFIX}"/usr/lib/lxd
}

src_compile() {
	export GOPATH="${S}/_dist"

	export CGO_CFLAGS="${CGO_CFLAGS} -I${GOPATH}/deps/dqlite/include/ -I${GOPATH}/deps/raft/include/"
	export CGO_LDFLAGS="${CGO_LDFLAGS} -L${GOPATH}/deps/dqlite/.libs/ -L${GOPATH}/deps/raft/.libs -Wl,-rpath,${EPREFIX}/usr/lib/lxd"
	export LD_LIBRARY_PATH="${GOPATH}/deps/dqlite/.libs/:${GOPATH}/deps/raft/.libs/:${LD_LIBRARY_PATH}"

	local j
	for j in raft; do
		cd "${GOPATH}"/deps/${j} || die
		emake
	done

	cd "${GOPATH}/deps/dqlite" || die
	emake CFLAGS="-I${GOPATH}/deps/raft/include" LDFLAGS="-L${GOPATH}/deps/raft"

	cd "${S}" || die

	for k in fuidshift lxd-agent lxd-benchmark lxd-p2c lxc lxc-to-lxd; do
		go install -v -x ${EGO_PN}/${k} || die "failed compiling ${k}"
	done

	go install -v -x -tags libsqlite3 ${EGO_PN}/lxd || die "Failed to build the daemon"

	use nls && emake build-mo
}

src_test() {
	export GOPATH="${S}/_dist"

	export CGO_CFLAGS="${CGO_CFLAGS} -I${GOPATH}/deps/dqlite/include/ -I${GOPATH}/deps/raft/include/"
	export CGO_LDFLAGS="${CGO_LDFLAGS} -L${GOPATH}/deps/dqlite/.libs/ -L${GOPATH}/deps/raft/.libs -Wl,-rpath,${EPREFIX}/usr/lib/lxd"
	export LD_LIBRARY_PATH="${GOPATH}/deps/dqlite/.libs/:${GOPATH}/deps/raft/.libs:${LD_LIBRARY_PATH}"

	go test -v ${EGO_PN}/lxd || die
}

src_install() {
	local bindir="_dist/bin"
	export GOPATH="${S}/_dist"

	dosbin ${bindir}/lxd

	for l in fuidshift lxd-agent lxd-benchmark lxd-p2c lxc lxc-to-lxd; do
		dobin ${bindir}/${l}
	done

	for m in dqlite raft; do
		cd "${GOPATH}"/deps/${m} || die "failed switching into ${GOPATH}/${m}"
		emake DESTDIR="${D}" install
	done

	cd "${S}" || die

	# We only need bundled libs during src_compile, and we don't want anything
	# to link against these.
	rm -r "${ED}"/usr/include || die
	rm -r "${ED}"/usr/lib/lxd/*.a || die
	rm -r "${ED}"/usr/lib/lxd/pkgconfig || die

	newbashcomp scripts/bash/lxd-client lxc

	newinitd "${FILESDIR}"/${PV}/lxd.initd lxd || die
	newconfd "${FILESDIR}"/${PV}/lxd.confd lxd || die

	dodoc AUTHORS doc/*
	use nls && domo po/*.mo
}

pkg_postinst() {
	elog
	elog "Consult https://www.funtoo.org/LXD for more information,"
	elog "including a Quick Start."

	# The control socket will be owned by (and writeable by) this group.
	enewgroup lxd

	elog
	elog "Though not strictly required, some features are enabled at run-time"
	elog "when the relevant helper programs are detected:"
	elog "- sys-fs/btrfs-progs"
	elog "- sys-fs/lvm2"
	elog "- sys-fs/zfs"
	elog "- sys-process/criu"
	elog
	elog "Be sure to add your local user to the lxd group."
}
