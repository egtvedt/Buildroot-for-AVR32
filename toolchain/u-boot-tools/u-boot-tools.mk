#############################################################
#
# U-Boot tools
#
#############################################################
U_BOOT_TOOLS_VERSION:=1.2.0
U_BOOT_TOOLS_SOURCE:=u-boot-$(U_BOOT_TOOLS_VERSION).tar.bz2
U_BOOT_TOOLS_SITE:=ftp://ftp.denx.de/pub/u-boot
U_BOOT_TOOLS_DIR:=$(BUILD_DIR)/u-boot-$(U_BOOT_TOOLS_VERSION)
U_BOOT_TOOLS_CAT:=$(BZCAT)
U_BOOT_TOOLS_BIN:=mkimage

# The u-boot-tools target will compile both the general tools and the specific
# u-boot bootloader for the target board. Changing the steps here may have
# impact on target/bootloader/u-boot/u-boot.mk.

$(DL_DIR)/$(U_BOOT_TOOLS_SOURCE):
	 $(WGET) -P $(DL_DIR) $(U_BOOT_TOOLS_SITE)/$(U_BOOT_TOOLS_SOURCE)

$(U_BOOT_TOOLS_DIR)/.unpacked: $(DL_DIR)/$(U_BOOT_TOOLS_SOURCE)
	$(U_BOOT_TOOLS_CAT) $(DL_DIR)/$(U_BOOT_TOOLS_SOURCE) \
		| tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	toolchain/patch-kernel.sh $(U_BOOT_TOOLS_DIR) target/bootloader/u-boot/ \
		u-boot-$(U_BOOT_TOOLS_VERSION)-\*.patch\*
	touch $@

$(U_BOOT_TOOLS_DIR)/.configured: $(U_BOOT_TOOLS_DIR)/.unpacked
ifeq ($(BR2_TARGET_U_BOOT_CONFIG_BOARD),"")
	@echo
	@echo "	You did not specify a target u-boot config board, so u-boot"
	@echo "	has no way of knowing which board you want to build your"
	@echo "	bootloader for."
	@echo
	@echo "	Configure the BR2_TARGET_U_BOOT_CONFIG_BOARD variable."
	@echo
	@exit 1
endif
	$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		$(MAKE) -C $(U_BOOT_TOOLS_DIR) \
		$(BR2_TARGET_U_BOOT_CONFIG_BOARD)
	touch $@

$(U_BOOT_TOOLS_DIR)/tools/$(U_BOOT_TOOLS_BIN): $(U_BOOT_TOOLS_DIR)/.configured
	$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		$(MAKE) -C $(U_BOOT_TOOLS_DIR)
	cp -dpf $(U_BOOT_TOOLS_DIR)/tools/$(U_BOOT_TOOLS_BIN) $(STAGING_DIR)/usr/bin/

u-boot-tools: gcc $(U_BOOT_TOOLS_DIR)/tools/$(U_BOOT_TOOLS_BIN)

u-boot-tools-clean:
	$(MAKE) -C $(U_BOOT_TOOLS_DIR) clean
	rm -rf $(STAGING_DIR)/usr/bin/$(U_BOOT_TOOLS_BIN)

u-boot-tools-dirclean:
	rm -rf $(U_BOOT_TOOLS_DIR)

u-boot-tools-source: $(DL_DIR)/$(U_BOOT_TOOLS_SOURCE)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_TARGET_U_BOOT)),y)
TARGETS+=u-boot-tools
endif
