# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools db-use fcaps toolchain-funcs

DESCRIPTION="Linux-PAM (Pluggable Authentication Modules)"
HOMEPAGE="https://github.com/linux-pam/linux-pam"
PP="pambase-20190402"

LICENSE="|| ( BSD GPL-2 )"
SLOT="0"
KEYWORDS="*"
IUSE="audit berkdb +cracklib debug elogind minimal mktemp nis nls +nullok pam_krb5 pam_ssh passwdqc +pie securetty selinux +sha512 static-libs"

BDEPEND="app-text/docbook-xml-dtd:4.1.2
	app-text/docbook-xml-dtd:4.3
	app-text/docbook-xml-dtd:4.4
	app-text/docbook-xml-dtd:4.5
	dev-libs/libxslt
	sys-devel/flex
	virtual/pkgconfig
	nls? ( sys-devel/gettext )
	app-arch/xz-utils
	app-portage/portage-utils"
DEPEND="
	audit? ( >=sys-process/audit-2.2.2 )
	berkdb? ( >=sys-libs/db-4.8.30-r1:= )
	cracklib? ( >=sys-libs/cracklib-2.9.1-r1 )
	selinux? ( >=sys-libs/libselinux-2.2.2-r4 )
	nis? ( >=net-libs/libtirpc-0.2.4-r2 )
	nls? ( >=virtual/libintl-0-r1 )"
RDEPEND="${DEPEND}
	!sys-auth/openpam
	!sys-auth/pam_userdb
	!<sys-auth/pambase-20190426"
PDEPEND="
	passwdqc? ( sys-auth/pam_passwdqc )
	mktemp? ( sys-auth/pam_mktemp )
	pam_krb5? ( sys-auth/pam_krb5 )
	elogind? ( sys-auth/elogind[pam] )"

S="${WORKDIR}/linux-${P}"

GITHUB_REPO="linux-pam"
GITHUB_USER="linux-pam"
GITHUB_TAG="b136bff"
SRC_URI="https://www.github.com/${GITHUB_USER}/${GITHUB_REPO}/tarball/${GITHUB_TAG} -> ${PN}-${GITHUB_TAG}.tar.gz"
SRC_URI="$SRC_URI https://github.com/gentoo/pambase/archive/${PP}.tar.gz"

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}/${GITHUB_USER}-${GITHUB_REPO}"-??????? "${S}" || die
}

src_prepare() {
	default
	eapply "${FILESDIR}/pam-remove-browsers.patch" # remove elinks usage from configure.
	eapply "${FILESDIR}/pam-1.3.1-faillock.patch" # faillock support from Red Hat.
	touch ChangeLog || die
	eautoreconf
	cd ${WORKDIR}/pambase-${PP} || die
	eapply "${FILESDIR}/pambase-limits-optional.patch" # make attempt to apply limits but don't deny login. Good for lxd containers.
}

src_configure() {
	# Do not let user's BROWSER setting mess us up. #549684
	unset BROWSER

	# Disable automatic detection of libxcrypt; we _don't_ want the
	# user to link libxcrypt in by default, since we won't track the
	# dependency and allow to break PAM this way.

	export ac_cv_header_xcrypt_h=no

	local myconf=(
		--with-db-uniquename=-$(db_findver sys-libs/db)
		--enable-securedir="${EPREFIX}"/$(get_libdir)/security
		--libdir=/usr/$(get_libdir)
		--disable-prelude
		$(use_enable audit)
		$(use_enable berkdb db)
		$(use_enable cracklib)
		$(use_enable debug)
		$(use_enable nis)
		$(use_enable nls)
		$(use_enable pie)
		$(use_enable selinux)
		$(use_enable static-libs static)
		--enable-isadir='.' #464016
		)
	ECONF_SOURCE="${S}" econf ${myconf[@]}
}

src_compile() {
	emake -C "${S}/modules/pam_faillock" -f "${S}/modules/pam_faillock/Makefile" -f "${S}/Make.xml.rules" faillock.8 pam_faillock.8
	emake sepermitlockdir="${EPREFIX}/run/sepermit"

	use_var() {
		local varname=$(echo "$1" | tr '[:lower:]' '[:upper:]')
		local usename=${2-$(echo "$1" | tr '[:upper:]' '[:lower:]')}
		local varvalue=$(usex ${usename})
		echo "${varname}=${varvalue}"
	}
	
	cd ${WORKDIR}/pambase-${PP} || die

	emake \
		GIT=true \
		$(use_var debug) \
		$(use_var cracklib) \
		$(use_var passwdqc) \
		CONSOLEKIT=no \
		ELOGIND=yes \
		SYSTEMD=no \
		$(use_var selinux) \
		$(use_var nullok) \
		$(use_var mktemp) \
		$(use_var pam_ssh) \
		$(use_var securetty) \
		$(use_var sha512) \
		$(use_var KRB5 pam_krb5) \
		$(use_var minimal) \
		IMPLEMENTATION=linux-pam \
		LINUX_PAM_VERSION=0x010301
}

src_install() {
	emake DESTDIR="${D}" install \
		sepermitlockdir="${EPREFIX}/run/sepermit"

	local prefix
	prefix=
	gen_usr_ldscript -a pam pamc pam_misc

	# create extra symlinks just in case something depends on them...
	local lib
	for lib in pam pamc pam_misc; do
		if ! [[ -f "${ED}"${prefix}/$(get_libdir)/lib${lib}$(get_libname) ]]; then
			dosym lib${lib}$(get_libname 0) ${prefix}/$(get_libdir)/lib${lib}$(get_libname)
		fi
	done
	
	# faillock binary requires logging directory. We will use /var/log/faillock.
	keepdir /var/log/faillock
	find "${ED}" -type f -name '*.la' -delete || die

	if use selinux; then
		dodir /usr/lib/tmpfiles.d
		cat - > "${D}"/usr/lib/tmpfiles.d/${CATEGORY}:${PN}:${SLOT}.conf <<EOF
d /run/sepermit 0755 root root
EOF
	fi

	# pambase
	cd ${WORKDIR}/pambase-${PP} || die
	emake GIT=true DESTDIR=${ED} install
}

pkg_postinst() {
	ewarn "Some software with pre-loaded PAM libraries might experience"
	ewarn "warnings or failures related to missing symbols and/or versions"
	ewarn "after any update. While unfortunate this is a limit of the"
	ewarn "implementation of PAM and the software, and it requires you to"
	ewarn "restart the software manually after the update."
	ewarn ""
	ewarn "You can get a list of such software running a command like"
	ewarn "  lsof / | egrep -i 'del.*libpam\\.so'"
	ewarn ""
	ewarn "Alternatively, simply reboot your system."

	# The pam_unix module needs to check the password of the user which requires
	# read access to /etc/shadow only.
	fcaps cap_dac_override sbin/unix_chkpwd
}
