# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: librewolf-r0.eclass
# @MAINTAINER:
# aidanharris
# @AUTHOR:
# aidanharris
# @BLURB:
# @DESCRIPTION: librewolf customisation/configuration

if [[ ! ${_LIBREWOLF_R1} ]]; then

inherit git-r3

librewolf-r1_src_configure() {
local _PN="LibreWolf"
[[ "${PN}" == "librewolf-nightly" ]] && _PN="${_PN}-Nightly"
# stolen from the AUR PKGBUILD with irrelevant options removed (here irrelvant means the feature is controlled via a useflag so there's no need to unconditionally enable/disable it here. Only the common options we want to always apply are listed here)
cat >> "${S}/.mozconfig" <<END
ac_add_options --enable-application=browser

ac_add_options --prefix=/usr
ac_add_options --enable-release
ac_add_options --enable-hardening
ac_add_options --enable-rust-simd

# Branding
ac_add_options --enable-update-channel=release
ac_add_options --with-app-name='${PN}'
ac_add_options --with-app-basename='${_PN}'
ac_add_options --with-branding=browser/branding/${PN}
ac_add_options --with-distribution-id=io.gitlab.${PN}
ac_add_options --with-unsigned-addon-scopes=app,system
ac_add_options --allow-addon-sideload
export MOZ_REQUIRE_SIGNING=0

# Features
ac_add_options --disable-crashreporter
ac_add_options --disable-updater

# Disables crash reporting, telemetry and other data gathering tools
mk_add_options MOZ_CRASHREPORTER=0
mk_add_options MOZ_DATA_REPORTING=0
mk_add_options MOZ_SERVICES_HEALTHREPORT=0
mk_add_options MOZ_TELEMETRY_REPORTING=0
END

  # Disabling Pocket
  sed -i "s/'pocket'/#'pocket'/g" "${S}"/browser/components/moz.build
  # this one only to remove an annoying error message:
  sed -i 's#SaveToPocket.init();#// SaveToPocket.init();#g' "${S}"/browser/components/BrowserGlue.jsm

  # allow SearchEngines option in non-ESR builds
  sed -i 's#"enterprise_only": true,#"enterprise_only": false,#g' "${S}"/browser/components/enterprisepolicies/schemas/policies-schema.json

  rm -f ${WORKDIR}/common/source_files/mozconfig
  cp -r ${WORKDIR}/common/source_files/* "${S}"/
  if [[ "$PN" == "librewolf-nightly" ]]
  then
	  # This makes it so librewolf-nightly can be installed alongside librewolf using a different profile so things don't conflict
	  mv "${S}/browser/branding/librewolf"  "${S}/browser/branding/librewolf-nightly"
	  eapply "${FILESDIR}/librewolf-nightly-branding.diff"
  fi
}

librewolf-r1_src_unpack() {
	if [[ "$PN" == "librewolf-nightly" ]]
	then
		mercurial_src_unpack
	fi
	local git_repos=(
		"https://gitlab.com/librewolf-community/browser/common.git"
		"https://gitlab.com/librewolf-community/settings.git"
	)
	pushd "${WORKDIR}"
	for repo in ${git_repos[@]}
	do
		local _repo="${repo##*/}"
		_repo="${_repo%.git}"
		git-r3_fetch "$repo"
		git-r3_checkout "$repo" "${WORKDIR}/${_repo}"
	done
	popd
}

librewolf-r1_src_install() {
  local vendorjs="$ED/usr/$(get_libdir)/${PN}/browser/defaults/preferences/vendor.js"

  cat >> "$vendorjs" <<END
// Use system-provided dictionaries
pref("spellchecker.dictionary_path", "/usr/share/hunspell");

// Don't disable extensions in the application directory
// done in librewolf.cf
// pref("extensions.autoDisableScopes", 11);
END

  cp -r ${WORKDIR}/settings/* ${ED}/usr/$(get_libdir)/${PN}/

  local distini="$ED/usr/$(get_libdir)/${PN}/distribution/distribution.ini"
  install -Dvm644 /dev/stdin "$distini" <<END
[Global]
id=io.gitlab.${_pkgname}
version=1.0
about=LibreWolf

[Preferences]
app.distributor="LibreWolf Community"
app.distributor.channel=${PN}
app.partner.librewolf=${PN}
END
}

_LIBREWOLF_R1=1
fi
