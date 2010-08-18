#############################################################
#
# Linux Test Project
#
#############################################################
LTP_VERSION:=20100630
LTP_SOURCE:=ltp-full-$(LTP_VERSION).bz2
LTP_SITE:=http://$(BR2_SOURCEFORGE_MIRROR).dl.sourceforge.net/sourceforge/ltp
LTP_INSTALL_STAGING=NO
LTP_INSTALL_TARGET=YES
LTP_DEPENDENCIES = host-fakeroot

define LTP_CONFIGURE_CMDS
	$(MAKE) -C $(@D) autotools
	cd $(@D) && rm -f config.cache &&		\
		$(TARGET_CONFIGURE_OPTS)		\
		$(TARGET_CONFIGURE_ARGS)		\
		./configure				\
			--host=$(GNU_TARGET_NAME)	\
			--build=$(GNU_HOST_NAME)
endef

define LTP_BUILD_CMDS
	$(MAKE) -C $(@D) all
endef

define LTP_INSTALL_TARGET_CMDS
	echo '$(MAKE) -C $(@D) DESTDIR="$(TARGET_DIR)" install'	\
		> $(BUILD_DIR)/.fakeroot.ltp
endef

$(eval $(call GENTARGETS,package,ltp))
