################################################################################
#
# xserver_xorg-server -- No description available
#
################################################################################

XSERVER_XORG_SERVER_VERSION = 1.4
XSERVER_XORG_SERVER_SOURCE = xorg-server-$(XSERVER_XORG_SERVER_VERSION).tar.bz2
XSERVER_XORG_SERVER_SITE = http://xorg.freedesktop.org/releases/individual/xserver
XSERVER_XORG_SERVER_AUTORECONF = NO
XSERVER_XORG_SERVER_INSTALL_STAGING = YES
XSERVER_XORG_SERVER_DEPENDENCIES =  freetype xutil_util-macros xlib_libXfont libdrm xlib_libxkbui \
									xproto_compositeproto xproto_damageproto xproto_fixesproto \
									xproto_glproto xproto_kbproto xproto_randrproto freetype \
									xlib_libX11 xlib_libXau xlib_libXaw xlib_libXdmcp xlib_libXScrnSaver \
									xlib_libXext xlib_libXfixes xlib_libXi xlib_libXmu xlib_libXpm \
									xlib_libXrender xlib_libXres xlib_libXtst xlib_libXft xlib_libXcursor \
									xlib_libXinerama xlib_libXrandr xlib_libXdamage xlib_libXxf86misc xlib_libXxf86vm \
									xlib_liblbxutil xlib_libxkbfile xlib_xtrans xdata_xbitmaps xproto_bigreqsproto \
									xproto_evieext xproto_fontsproto xproto_inputproto xproto_recordproto xproto_renderproto \
									xproto_resourceproto xproto_trapproto xproto_videoproto xproto_xcmiscproto \
									xproto_xextproto xproto_xf86bigfontproto xproto_xf86dgaproto xproto_xf86driproto \
									xproto_xf86miscproto xproto_xf86rushproto xproto_xf86vidmodeproto xproto_xproto \
									pixman dbus mcookie 

XSERVER_XORG_SERVER_CONF_OPT = --enable-kdrive --enable-xfbdev --enable-freetype --disable-kbd_mode --disable-xorg \
								--disable-config-hal CFLAGS="-I$(STAGING_DIR)/usr/include/pixman-1"

XSERVER_XORG_SERVER_INSTALL_TARGET_OPT = DESTDIR=$(TARGET_DIR) install

$(eval $(call AUTOTARGETS,package/x11r7,xserver_xorg-server))
