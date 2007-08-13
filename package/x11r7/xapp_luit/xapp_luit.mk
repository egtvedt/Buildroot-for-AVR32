################################################################################
#
# xapp_luit -- Locale and ISO 2022 support for Unicode terminals
#
################################################################################

XAPP_LUIT_VERSION = 1.0.2
XAPP_LUIT_SOURCE = luit-$(XAPP_LUIT_VERSION).tar.bz2
XAPP_LUIT_SITE = http://xorg.freedesktop.org/releases/individual/app
XAPP_LUIT_AUTORECONF = YES
XAPP_LUIT_DEPENDANCIES = xlib_libX11 xlib_libfontenc

$(eval $(call AUTOTARGETS,xapp_luit))
