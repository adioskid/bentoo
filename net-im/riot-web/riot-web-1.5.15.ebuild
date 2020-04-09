# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# NETWORK ACCESS
#
# this ebuild requires internet access! because javascript packaging.
#
# to allow network access just for this package:
#
# * /etc/portage/env/networkaccess:
#   FEATURES="${FEATURES} -network-sandbox"
#
# * /etc/portage/package.env/package.env:
#   net-im/riot-web networkaccess
#
# this avoids disabling `network-sandbox` globally.


EAPI=6

DESCRIPTION="A glossy Matrix collaboration client for the web"
HOMEPAGE="https://riot.im"


if [[ ${PV} == "9999" ]]; then
	SCM="git-r3"

	SRC_URI=""
	EGIT_REPO_URI="git://github.com/vector-im/riot-web.git"
	EGIT_BRANCH="develop"
else
	SRC_URI="https://github.com/vector-im/riot-web/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

inherit eutils ${SCM}

LICENSE="Apache-2.0 MIT BSD"
SLOT="0"

# TODO: proper abi definition, as electon supports many other archs
#       but we can only create one of them currently
#       maybe get inspired by icedtea-bin
IUSE="abi_x86_32 abi_x86_64"
REQUIRED_USE="^^ ( abi_x86_32 abi_x86_64 )"

JSPKG="yarn"  # or npm

# get dependencies via readelf -a riot-web...
DEPEND_ALL="
	x11-libs/cairo
	x11-libs/pango
	media-libs/fontconfig
"
if [[ ${JSPKG} == "yarm" ]]; then
	DEPEND="$DEPEND_ALL sys-apps/yarn"
elif [[ ${JSPKG} == "npm" ]]; then
	DEPEND="$DEPEND_ALL net-libs/nodejs[npm]"
fi

RDEPEND="${DEPEND}"

DESTPATH="opt/riot-web"


QA_PREBUILT="
	${DESTPATH}/libffmpeg.so
	${DESTPATH}/libnode.so
	${DESTPATH}/riot-web
"

src_prepare() {
	default
	$JSPKG install || die "$JSPKG module installation failed"

	if [[ ${PV} == "9999" ]]; then
		pushd ${S}/node_modules/
		rm -rf matrix-js-sdk
		git clone https://github.com/matrix-org/matrix-js-sdk --branch develop
		pushd matrix-js-sdk
		$JSPKG install
		popd
		popd
	fi

	if [[ ${PV} == "9999" ]]; then
		pushd ${S}/node_modules/
		rm -rf matrix-react-sdk
		git clone https://github.com/matrix-org/matrix-react-sdk --branch develop
		pushd matrix-react-sdk
		$JSPKG install
		popd
		popd
	fi
}

src_compile() {
	cp ${S}/config.sample.json ${S}/config.json

	$JSPKG run build || die "build failed"
	$JSPKG run install:electron || die "electron install failed"

	if use abi_x86_32; then
		${S}/node_modules/.bin/electron-builder --linux --ia32 --dir || die "bundling failed"
	elif use abi_x86_64; then
		${S}/node_modules/.bin/electron-builder --linux --x64 --dir || die "bundling failed"
	fi
}

src_install() {
	pushd ${S}/electron_app/dist/linux-unpacked
	insinto ${DESTPATH}
	exeinto ${DESTPATH}
	dodoc LICENSE*
	doins -r locales resources
	doins *.{pak,bin,dat}
	doins *.so
	doexe ${PN}
	popd

	dosym ../../${DESTPATH}/${PN} usr/bin/${PN}
}
