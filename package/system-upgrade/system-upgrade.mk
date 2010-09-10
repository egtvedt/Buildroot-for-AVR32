SYSTEM_UPGRADE_VERSION	:= 1.0
SYSTEM_UPGRADE_SOURCE	:= system-upgrade-$(SYSTEM_UPGRADE_VERSION).tar.bz2
SYSTEM_UPGRADE_SITE	:= http://avr32linux.org/twiki/pub/Main/SystemUpgrade

define SYSTEM_UPGRADE_BUILD_CMDS
	$(MAKE) -C $(@D) BOARD=$(BR2_PACKAGE_SYSTEM_UPGRADE_BOARD_NAME) CROSS_COMPILE=$(TARGET_CROSS)
endef

define SYSTEM_UPGRADE_INSTALL_TARGET_CMDS
	install -m 755 $(@D)/system-upgrade $(TARGET_DIR)/sbin/system-upgrade
	sed -e 's#@IMAGE_PATH@#/mnt/$(BR2_BOARD_NAME)-upgrade#'		\
		package/system-upgrade/upgrade.sysvinit.in		\
		> $(TARGET_DIR)/etc/init.d/S99upgrade
	chmod 0755 $(TARGET_DIR)/etc/init.d/S99upgrade
endef

$(eval $(call GENTARGETS,package,system-upgrade))
