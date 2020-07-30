# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 )
USE_RUBY="ruby25 ruby26 ruby27"
KFMIN=5.70.0
QTMIN=5.14.2
inherit ecm kde.org python-single-r1 ruby-single

DESCRIPTION="Kross interpreter plugins for programming languages"

LICENSE="GPL-2" # TODO: CHECK
SLOT="5"
KEYWORDS="amd64 ~arm64 x86"
IUSE="+python ruby"

REQUIRED_USE="|| ( python ruby ) python? ( ${PYTHON_REQUIRED_USE} )"

DEPEND="
	>=dev-qt/qtgui-${QTMIN}:5
	>=dev-qt/qtwidgets-${QTMIN}:5
	>=kde-frameworks/kross-${KFMIN}:5
	python? ( ${PYTHON_DEPS} )
	ruby? ( ${RUBY_DEPS} )
"
RDEPEND="${DEPEND}"

pkg_setup() {
	use python && python-single-r1_pkg_setup
	ecm_pkg_setup
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_python=$(usex python)
		-DBUILD_ruby=$(usex ruby)
	)

	ecm_src_configure
}
