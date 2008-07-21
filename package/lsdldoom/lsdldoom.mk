#############################################################
#
# lsdldoom
#
#############################################################

LSDLDOOM_VERSION = 1.4.4.4
LSDLDOOM_SOURCE = lsdldoom-$(LSDLDOOM_VERSION).tar.gz
LSDLDOOM_SITE = http://firehead.org/~jessh/lsdldoom/src
LSDLDOOM_AUTORECONF = NO
LSDLDOOM_INSTALL_STAGING = NO
LSDLDOOM_INSTALL_TARGET = YES
LSDLDOOM_INSTALL_TARGET_OPT = DESTDIR=$(TARGET_DIR) install

LSDLDOOM_MAKE_ENV = CC=$(TARGET_CC)

LSDLDOOM_CONF_OPT = --target=$(GNU_TARGET_NAME) --host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) --prefix=/usr \
		$(DISABLE_NLS)

LSDLDOOM_DEPENDENCIES = sdl

$(eval $(call AUTOTARGETS,package,lsdldoom))
