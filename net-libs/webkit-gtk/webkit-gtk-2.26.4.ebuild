# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="GTK+ port of WebKit. Funtoo uses WebKit itself, so this is a placeholder."
HOMEPAGE="https://www.webkit.org"

LICENSE="LGPL-2+ BSD"
SLOT="4/37" # soname version of libwebkit2gtk-4.0
KEYWORDS="*"

IUSE="+introspection wayland +X"
RDEPEND="=net-libs/webkit-255475*[introspection?,wayland?,X?]"

