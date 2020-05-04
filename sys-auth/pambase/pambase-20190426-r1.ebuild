# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="PAM base configuration files (virtual)"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="consolekit cracklib debug elogind minimal mktemp nullok pam_krb5 pam_ssh passwdqc securetty selinux sha512"

RDEPEND="
sys-libs/pam
consolekit? ( sys-auth/consolekit[pam] )
cracklib? ( sys-libs/pam[cracklib=] )
debug? ( sys-libs/pam[debug=] )
elogind? ( sys-auth/elogind[pam] )
minimal? ( sys-libs/pam[minimal=] )
mktemp? ( sys-libs/pam[mktemp=] )
nullok? ( sys-libs/pam[nullok=] )
pam_krb5? ( sys-libs/pam[pam_krb5=] )
pam_ssh? ( sys-libs/pam[pam_ssh=] )
passwdqc? ( sys-libs/pam[passwdqc=] )
securetty? ( sys-libs/pam[securetty=] )
selinux? ( sys-libs/pam[selinux=] )
sha512? ( sys-libs/pam[sha512=] )
"
