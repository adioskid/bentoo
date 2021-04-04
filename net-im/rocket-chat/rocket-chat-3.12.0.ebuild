# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit user

DESCRIPTION="The ultimate open source web chat platform"
HOMEPAGE="https://rocket.chat/"
SRC_URI="https://cdn-download.rocket.chat/build/rocket.chat-${PV}.tgz -> ${P}.tar.gz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND=">=dev-db/mongodb-3.6
		net-libs/nodejs
		media-gfx/imagemagick[jpeg,png]"
DEPEND="${RDEPEND}"
RESTRICT="network-sandbox"

NODEJS_VERSION="12.18.4"
ROCKET_DEST="/usr/share/${PN}"
ROCKET_LOG="/var/log/${PN}"
ROCKET_USER="rocket"
ROCKET_GROUP="daemon"

pkg_setup() {
	enewgroup ${ROCKET_GROUP}
	enewuser ${ROCKET_USER} -1 -1 ${ROCKET_DEST} "${ROCKET_GROUP}"
}

src_unpack()
{
	default
	mv "$WORKDIR/"* "$WORKDIR/$P"
}

src_prepare()
{
	default
	export NPM_CONFIG_PREFIX="${WORKDIR}/${P}"
	test -d $NPM_CONFIG_PREFIX || mkdir $NPM_CONFIG_PREFIX
	npm install n || die "Error installing n"
	N_PREFIX="${WORKDIR}/${P}/node"

	elog "Installing node v${NODEJS_VERSION} in $N_PREFIX ..."
	N_PREFIX=$N_PREFIX $NPM_CONFIG_PREFIX/node_modules/n/bin/n -q ${NODEJS_VERSION} &>/dev/null || \
		die "Error installing node v${NODEJS_VERSION}"

	PATH=$N_PREFIX/n/versions/node/$NODEJS_VERSION/bin:$PATH
	elog "Using $(which node) $(node --version) ..."
	elog "Installing rocker-chat ..."
	pushd programs/server &>/dev/null || die "Cannot find programs/server"
	npm install || die "Error in npm install in programs/server"
	popd
}

src_install()
{
	mkdir -p "${D}${ROCKET_DEST}"
	cp -a . "${D}${ROCKET_DEST}"

	keepdir "${ROCKET_LOG}"
	fowners "${ROCKET_USER}:${ROCKET_GROUP}" "${ROCKET_LOG}"

	# This is to enable webhook integration with script support
	keepdir "${ROCKET_DEST}/.babel-cache"
	fowners "${ROCKET_USER}:${ROCKET_GROUP}" "${ROCKET_DEST}/.babel-cache"

	newconfd "${FILESDIR}/${PN}-conf.d" "rocket-chat"
	newinitd "${FILESDIR}/${PN}-init.d" "rocket-chat"
}
