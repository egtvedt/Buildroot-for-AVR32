#############################################################
#
# U-Boot
#
#############################################################
U_BOOT_VER:=1.2.0
U_BOOT_SOURCE:=u-boot-$(U_BOOT_VER).tar.bz2
U_BOOT_SITE:=ftp://ftp.denx.de/pub/u-boot
U_BOOT_DIR:=$(BUILD_DIR)/u-boot-$(U_BOOT_VER)
U_BOOT_CAT:=$(BZCAT)
U_BOOT_BIN:=u-boot.bin

# The $(U_BOOT_DIR)/$(U_BOOT_BIN) is already built when we made the
# u-boot-tools, so there is no point in loading a config and compile.
# We just check if it is really there.
#
# If in the future building u-boot-tools is optional, then this rule needs to
# be changed to first load the config (BR2_TARGET_U_BOOT_CONFIG_BOARD) and then
# compile u-boot.

$(U_BOOT_DIR)/$(U_BOOT_BIN):
	@touch -c $@

$(TOPDIR)/u-boot-$(BR2_TARGET_U_BOOT_CONFIG_BOARD).bin: $(U_BOOT_DIR)/$(U_BOOT_BIN)
	cp -dpf $(U_BOOT_DIR)/$(U_BOOT_BIN) $(TOPDIR)/u-boot-$(BR2_TARGET_U_BOOT_CONFIG_BOARD).bin

u-boot: $(TOPDIR)/u-boot-$(BR2_TARGET_U_BOOT_CONFIG_BOARD).bin

u-boot-clean:
	$(MAKE) -C $(U_BOOT_DIR) clean

u-boot-dirclean:
	rm -rf $(U_BOOT_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_TARGET_U_BOOT)),y)
TARGETS+=u-boot
endif
