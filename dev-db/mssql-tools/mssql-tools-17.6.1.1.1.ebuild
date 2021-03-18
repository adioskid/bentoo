# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit unpacker wrapper

DESCRIPTION="SQL Server command-line tools on Linux"
HOMEPAGE="https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools?view=sql-server-linux-2017"
SRC_URI="https://packages.microsoft.com/debian/10/prod/pool/main/m/mssql-tools/mssql-tools_$(ver_rs 4 -)_amd64.deb"

LICENSE="mssql-tools"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
RESTRICT="bindist mirror strip"

RDEPEND="
	dev-db/msodbcsql
	dev-libs/openssl
	virtual/krb5
"

S="${WORKDIR}"
QA_PREBUILT="opt/mssql-tools/*"

src_unpack() {
	unpack_deb ${A}
}

src_install() {
	dodoc -r usr/share/doc
	doins -r opt
	for bin in bcp sqlcmd; do
		fperms +x /opt/mssql-tools/bin/$bin
		make_wrapper $bin /opt/mssql-tools/bin/$bin
	done
}
