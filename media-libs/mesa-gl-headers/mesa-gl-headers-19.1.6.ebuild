# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Mesa's GL headers -- separated out to resolve circ. deps."
HOMEPAGE="https://mesa3d.org"
SRC_URI="https://fastpull-us.funtoo.org/distfiles/mesa-gl-headers-${PVR}.tar.xz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""
S="${WORKDIR}"
RDEPEND="!<media-libs/mesa-19.1.4"

src_unpack() {
	return
}

# A quick way to generate a new headers archive based on the contents of the previous archive:
# for x in $(cat /var/db/pkg/media-libs/mesa-gl-headers-19.1.3-r3/CONTENTS | cut -f2 -d" " | grep .h$); do 
#	basefile=${x##/usr/include/}
#	basedir=${basefile%/*}
#	echo $basefile $basedir
#	[ -n $basedir ] && [ "$basedir" != "$basefile" ] && install -d /var/tmp/mhl/$basedir
#	cp $x /var/tmp/mhl/$basefile
# done
# cd /var/tmp/mhl; tar cvf /var/cache/portage/distfiles/mesa-gl-headers-FOO-tar .
# xz /var/cache/portage/distfiles/mesa-gl-headers-FOO.tar

src_install() {
	dodir /usr/include
	(cd ${D}/usr/include && tar xvf ${DISTDIR}/mesa-gl-headers-${PVR}.tar.xz) || die "extract failed"
}
