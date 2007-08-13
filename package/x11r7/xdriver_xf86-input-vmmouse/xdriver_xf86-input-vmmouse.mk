################################################################################
#
# xdriver_xf86-input-vmmouse -- VMWare mouse input driver
#
################################################################################

XDRIVER_XF86_INPUT_VMMOUSE_VERSION = 12.4.0
XDRIVER_XF86_INPUT_VMMOUSE_SOURCE = xf86-input-vmmouse-$(XDRIVER_XF86_INPUT_VMMOUSE_VERSION).tar.bz2
XDRIVER_XF86_INPUT_VMMOUSE_SITE = http://xorg.freedesktop.org/releases/individual/driver
XDRIVER_XF86_INPUT_VMMOUSE_AUTORECONF = YES
XDRIVER_XF86_INPUT_VMMOUSE_DEPENDANCIES = xserver_xorg-server xproto_inputproto xproto_randrproto xproto_xproto

$(eval $(call AUTOTARGETS,xdriver_xf86-input-vmmouse))
