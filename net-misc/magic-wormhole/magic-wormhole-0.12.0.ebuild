# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_5 python3_6 python3_7 )

inherit distutils-r1

if [[ ${PV} = *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/warner/magic-wormhole.git"
	KEYWORDS=""
else
	KEYWORDS="~amd64"
	HASH_COMMIT="${PV}"
	SRC_URI="https://github.com/warner/magic-wormhole/archive/${HASH_COMMIT}.tar.gz -> ${P}.tar.gz"
fi

DESCRIPTION="Securely and simply transfer data between computers"
HOMEPAGE="https://github.com/warner/magic-wormhole"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+maelstrom-mailbox +maelstrom-transit"

RDEPEND="
	>=dev-python/attrs-19.2.0[${PYTHON_USEDEP}]
	>=dev-python/autobahn-0.14.1
	>=dev-python/spake2-0.8[${PYTHON_USEDEP}]
	>=dev-python/tqdm-4.13.0
	>=dev-python/twisted-17.5.0[${PYTHON_USEDEP}]
	>=dev-python/txtorcon-18.0.2
	dev-python/automat[${PYTHON_USEDEP}]
	dev-python/click[${PYTHON_USEDEP}]
	dev-python/future[${PYTHON_USEDEP}]
	dev-python/hkdf
	dev-python/humanize[${PYTHON_USEDEP}]
	dev-python/idna[${PYTHON_USEDEP}]
	dev-python/pynacl[${PYTHON_USEDEP}]
	dev-python/pyopenssl[${PYTHON_USEDEP}]
	dev-python/service_identity[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]
"
DEPEND="
	${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
"

python_prepare_all() {
	# Dirty fix because twisted-tls is not recognised as a real dependency, but
	# we made sure pyOpenSSL, service_identity and idna are built anyway.
	sed -i -e '/twisted\[tls\]/d' setup.py || die "Sed failed!"

	# Replacing Warner's personal relays with my own. Same deal - if it gets
	# out of hand, I'll shut it down.
	if use maelstrom-mailbox; then
		sed -i -e 's|ws://relay.magic-wormhole.io:4000/v1|ws://maelstrom.ninja:4000/v1|' src/wormhole/cli/public_relay.py || die "Sed failed!"
	fi
	if use maelstrom-transit; then
		sed -i -e 's|tcp:transit.magic-wormhole.io:4001|tcp:maelstrom.ninja:4001|' src/wormhole/cli/public_relay.py || die "Sed failed!"
	fi

	distutils-r1_python_prepare_all
}
