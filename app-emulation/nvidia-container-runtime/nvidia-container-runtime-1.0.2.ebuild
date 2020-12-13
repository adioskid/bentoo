# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils multilib

DESCRIPTION="nvidia-container-runtime (clone of runc with nvidia hooks) and the hook itself."
HOMEPAGE="https://github.com/NVIDIA"
KEYWORDS="*"

LICENSE="Apache-2.0"
SLOT="0"
IUSE="+seccomp"

COMMON_DEPEND="virtual/libnvidia-container"
DEPEND="$COMMON_DEPEND >=dev-lang/go-1.4:="
RDEPEND="$COMMON_DEPEND seccomp? ( sys-libs/libseccomp )"

TARBALL_PV=${PV}
GITHUB_REPO="runc"
GITHUB_USER="opencontainers"
GITHUB_TAG="da20211" # 2019-04-01

NV_GITHUB_REPO="nvidia-container-runtime"
NV_GITHUB_USER="NVIDIA"
NV_GITHUB_TAG="03af0a8" # 2019-04-01

SRC_URI="https://www.github.com/${GITHUB_USER}/${GITHUB_REPO}/tarball/${GITHUB_TAG} -> ${GITHUB_REPO}-${GITHUB_TAG}.tar.gz
https://www.github.com/${NV_GITHUB_USER}/${NV_GITHUB_REPO}/tarball/${NV_GITHUB_TAG} -> ${NV_GITHUB_REPO}-${NV_GITHUB_TAG}.tar.gz"
S=$WORKDIR/src/github.com/opencontainers/runc

src_unpack() {
	unpack ${A}
	mkdir -p $WORKDIR/src/github.com/opencontainers
	mv "${WORKDIR}/${GITHUB_USER}-${GITHUB_REPO}"-??????? $S || die
	mv "${WORKDIR}/${NV_GITHUB_USER}-${NV_GITHUB_REPO}"-??????? $WORKDIR/${NV_GITHUB_REPO} || die
	cd $WORKDIR/$NV_GITHUB_REPO/hook/nvidia-container-runtime-hook || die
	# GOPATH expects a "src", not a "vendor" directory:
	mv vendor src || die
}

PATCHES=( "$FILESDIR/0001-Add-prestart-hook-nvidia-container-runtime-hook-to-t.patch" )

src_prepare() {
	default
#	cd $WORKDIR/$NV_GITHUB_REPO && eapply $FILESDIR/nvidia-container-runtime-hook-gentoo-video-group.patch
}

src_compile() {
	# BEGIN nvidia-container-runtime build:

	export CGO_CFLAGS="-I${ROOT}/usr/include"
	export CGO_LDFLAGS="-L${ROOT}/usr/$(get_libdir)"
	export GOPATH=$WORKDIR

	local options=( $(usex seccomp "seccomp") )

	emake BUILDTAGS="${options[@]}"

	# BEGIN nvidia-container-runtime-hook build:

	cd $WORKDIR/$NV_GITHUB_REPO/hook/nvidia-container-runtime-hook || die
	export GOPATH=`pwd`
	go build || die
}

src_install() {
	newbin runc nvidia-container-runtime
	dobin $WORKDIR/$NV_GITHUB_REPO/hook/nvidia-container-runtime-hook/nvidia-container-runtime-hook
}
