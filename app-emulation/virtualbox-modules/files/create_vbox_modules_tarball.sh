#!/bin/bash

# Create a virtualbox modules tarball from a VirtualBox binary package.
# We can download the latest version package with this script
#
# usage: create_vbox_modules_tarball.sh [VirtualBox-4.1.18-78361-Linux_amd64.run]

if [ "$1" ]; then
	[ -f "$1" ] || exit 1
	VBOX_PACKAGE="$1"
	VERSION_SUFFIX=""
	if [[ ${VBOX_PACKAGE} = *_BETA* ]] || [[ ${VBOX_PACKAGE} = *_RC* ]] ; then
		VERSION_SUFFIX="$(echo ${VBOX_PACKAGE} | sed 's@.*VirtualBox-[[:digit:]\.]\+\(_[[:alpha:]]\+[[:digit:]]\).*@\L\1@')"
	fi
	VBOX_VER="$(echo ${VBOX_PACKAGE} | sed 's@.*VirtualBox-\([[:digit:]\.]\+\).*@\1@')${VERSION_SUFFIX}"
else
	VBOX_VER="$(wget -q -O - http://download.virtualbox.org/virtualbox/LATEST.TXT |head -n 1 )"
	VBOX_PACKAGE="$(wget -q -O - http://download.virtualbox.org/virtualbox/${VBOX_VER} | grep -E -o VirtualBox-[0-9.-]+Linux_amd64.run | head -n 1 )"
	[ -f "${VBOX_PACKAGE}" ] || wget -nv --show-progress http://download.virtualbox.org/virtualbox/${VBOX_VER}/${VBOX_PACKAGE} || exit 1
fi

sh ${VBOX_PACKAGE} --noexec --keep --nox11 || exit 2
cd install || exit 3
tar -xaf VirtualBox.tar.bz2 || exit 4
cd src/vboxhost || exit 5
tar -cvJf ../../../vbox-kernel-module-src-${VBOX_VER}.tar.xz . || exit 6
cd ../../.. && rm install -rf

exit 0
