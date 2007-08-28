#############################################################
#
# U-Boot
#
#############################################################
U_BOOT_VERSION:=1.2.0
U_BOOT_SOURCE:=u-boot-$(U_BOOT_VERSION).tar.bz2
U_BOOT_SITE:=ftp://ftp.denx.de/pub/u-boot
U_BOOT_DIR:=$(PROJECT_BUILD_DIR)/u-boot-$(U_BOOT_VERSION)
U_BOOT_CAT:=$(BZCAT)
U_BOOT_BIN:=u-boot.bin
U_BOOT_TOOLS_BIN:=mkimage

$(DL_DIR)/$(U_BOOT_SOURCE):
	 $(WGET) -P $(DL_DIR) $(U_BOOT_SITE)/$(U_BOOT_SOURCE)

$(U_BOOT_DIR)/.unpacked: $(DL_DIR)/$(U_BOOT_SOURCE)
	$(U_BOOT_CAT) $(DL_DIR)/$(U_BOOT_SOURCE) \
		| tar -C $(PROJECT_BUILD_DIR) $(TAR_OPTIONS) -
	toolchain/patch-kernel.sh $(U_BOOT_DIR) target/bootloader/u-boot/ \
		u-boot-$(U_BOOT_VERSION)-\*.patch\*
	touch $@

$(U_BOOT_DIR)/.configured: $(U_BOOT_DIR)/.unpacked
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
	$(TARGET_CONFIGURE_OPTS)		\
		CFLAGS="$(TARGET_CFLAGS)"	\
		LDFLAGS="$(TARGET_LDFLAGS)"	\
		$(MAKE) -C $(U_BOOT_DIR)	\
		$(BR2_TARGET_U_BOOT_CONFIG_BOARD)
	touch $@

$(U_BOOT_DIR)/$(U_BOOT_BIN): $(U_BOOT_DIR)/.configured
	$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		$(MAKE) -C $(U_BOOT_DIR)

$(BINARIES_DIR)/$(U_BOOT_BIN): $(U_BOOT_DIR)/$(U_BOOT_BIN)
	cp -dpf $(U_BOOT_DIR)/$(U_BOOT_BIN) $(BINARIES_DIR)
	cp -dpf $(U_BOOT_DIR)/tools/$(U_BOOT_TOOLS_BIN) $(STAGING_DIR)/usr/bin/

u-boot: gcc $(BINARIES_DIR)/$(U_BOOT_BIN)

u-boot-clean:
	$(MAKE) -C $(U_BOOT_DIR) clean

u-boot-dirclean:
	rm -rf $(U_BOOT_DIR)

u-boot-source: $(DL_DIR)/$(U_BOOT_SOURCE)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_TARGET_U_BOOT)),y)
TARGETS+=u-boot
endif
