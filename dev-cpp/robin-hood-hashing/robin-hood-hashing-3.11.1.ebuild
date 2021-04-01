# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Fast & memory efficient hashtable based on robin hood hashing for C++11/14/17/20"
HOMEPAGE="https://github.com/martinus/robin-hood-hashing"

if [[ ${PV} == 9999 ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/martinus/robin-hood-hashing"
else
	SRC_URI="https://github.com/martinus/robin-hood-hashing/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="amd64 ~arm ~arm64 ~ppc64 x86"
fi

LICENSE="MIT"
SLOT="0"
