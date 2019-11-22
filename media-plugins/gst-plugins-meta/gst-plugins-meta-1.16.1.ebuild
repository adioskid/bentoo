# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit multilib-build

DESCRIPTION="Meta ebuild to pull in gst plugins for apps"
HOMEPAGE="https://gstreamer.freedesktop.org/"

LICENSE="metapackage"
SLOT="1.0"
KEYWORDS="alpha amd64 arm arm64 ~hppa ia64 ~mips ppc ppc64 ~sparc x86 ~amd64-fbsd"
IUSE="aac a52 alsa cdda dts dv dvb dvd ffmpeg flac http jack lame libass libvisual mms mp3 modplug mpeg ogg opus oss pulseaudio taglib theora v4l vaapi vcd vorbis vpx wavpack X x264"
REQUIRED_USE="opus? ( ogg ) theora? ( ogg ) vorbis? ( ogg )"

RDEPEND="
	>=media-libs/gstreamer-${PV}:1.0
	>=media-libs/gst-plugins-base-${PV}:1.0[alsa?,ogg?,theora?,vorbis?,X?]
	>=media-libs/gst-plugins-good-${PV}:1.0
	a52? ( >=media-plugins/gst-plugins-a52dec-${PV}:1.0 )
	aac? ( >=media-plugins/gst-plugins-faad-${PV}:1.0 )
	cdda? ( || (
		>=media-plugins/gst-plugins-cdparanoia-${PV}:1.0
		>=media-plugins/gst-plugins-cdio-${PV}:1.0 ) )
	dts? ( >=media-plugins/gst-plugins-dts-${PV}:1.0 )
	dv? ( >=media-plugins/gst-plugins-dv-${PV}:1.0 )
	dvb? (
		>=media-plugins/gst-plugins-dvb-${PV}:1.0
		>=media-libs/gst-plugins-bad-${PV}:1.0 )
	dvd? (
		>=media-libs/gst-plugins-ugly-${PV}:1.0
		>=media-plugins/gst-plugins-a52dec-${PV}:1.0
		>=media-plugins/gst-plugins-dvdread-${PV}:1.0
		>=media-plugins/gst-plugins-mpeg2dec-${PV}:1.0
		>=media-plugins/gst-plugins-resindvd-${PV}:1.0 )
	ffmpeg? ( >=media-plugins/gst-plugins-libav-1.14.2:1.0 )
	flac? ( >=media-plugins/gst-plugins-flac-${PV}:1.0 )
	http? ( >=media-plugins/gst-plugins-soup-${PV}:1.0 )
	jack? ( >=media-plugins/gst-plugins-jack-${PV}:1.0 )
	lame? ( >=media-plugins/gst-plugins-lame-${PV}:1.0 )
	libass? ( >=media-plugins/gst-plugins-assrender-${PV}:1.0 )
	libvisual? ( >=media-plugins/gst-plugins-libvisual-${PV}:1.0 )
	mms? ( >=media-plugins/gst-plugins-libmms-${PV}:1.0 )
	modplug? ( >=media-plugins/gst-plugins-modplug-${PV}:1.0 )
	mp3? (
		>=media-libs/gst-plugins-ugly-${PV}:1.0
		>=media-plugins/gst-plugins-mpg123-${PV}:1.0 )
	mpeg? ( >=media-plugins/gst-plugins-mpeg2dec-${PV}:1.0 )
	opus? ( >=media-plugins/gst-plugins-opus-${PV}:1.0 )
	oss? ( >=media-plugins/gst-plugins-oss-${PV}:1.0 )
	pulseaudio? ( >=media-plugins/gst-plugins-pulse-${PV}:1.0 )
	taglib? ( >=media-plugins/gst-plugins-taglib-${PV}:1.0 )
	v4l? ( >=media-plugins/gst-plugins-v4l2-${PV}:1.0 )
	vaapi? ( >=media-plugins/gst-plugins-vaapi-${PV}:1.0 )
	vcd? (
		>=media-plugins/gst-plugins-mplex-${PV}:1.0
		>=media-plugins/gst-plugins-mpeg2dec-${PV}:1.0 )
	vpx? ( >=media-plugins/gst-plugins-vpx-${PV}:1.0 )
	wavpack? ( >=media-plugins/gst-plugins-wavpack-${PV}:1.0 )
	x264? ( >=media-plugins/gst-plugins-x264-${PV}:1.0 )
"

# Usage note:
# The idea is that apps depend on this for optional gstreamer plugins.  Then,
# when USE flags change, no app gets rebuilt, and all apps that can make use of
# the new plugin automatically do.

# When adding deps here, make sure the keywords on the gst-plugin are valid.
