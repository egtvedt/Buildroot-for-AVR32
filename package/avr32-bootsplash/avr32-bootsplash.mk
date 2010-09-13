################################################################
#
# Simple AVR32 bootsplash scripts
#
################################################################

AVR32_BOOTSPLASH_DIR	:= package/avr32-bootsplash

$(STAMP_DIR)/avr32_bootsplash_installed: $(wildcard $(AVR32_BOOTSPLASH_DIR)/*)
	$(INSTALL) -m 0755 $(AVR32_BOOTSPLASH_DIR)/bootsplash.sysvinit $(TARGET_DIR)/etc/init.d/S01bootsplash
	$(INSTALL) -m 0755 $(AVR32_BOOTSPLASH_DIR)/finalsplash.sysvinit $(TARGET_DIR)/etc/init.d/S99finalsplash
	$(INSTALL) -m 0644 $(AVR32_BOOTSPLASH_DIR)/bootsplash-$(BR2_BOARD_NAME).jpg $(TARGET_DIR)/etc/bootsplash.jpg
	$(INSTALL) -m 0644 $(AVR32_BOOTSPLASH_DIR)/finalsplash-$(BR2_BOARD_NAME).jpg $(TARGET_DIR)/etc/finalsplash.jpg
	touch $@

avr32-bootsplash: $(STAMP_DIR)/avr32_bootsplash_installed

avr32-bootsplash-clean:
	rm -f $(TARGET_DIR)/etc/init.d/S01bootsplash
	rm -f $(TARGET_DIR)/etc/init.d/S99finalsplash
	rm -f $(TARGET_DIR)/etc/bootsplash.jpg
	rm -f $(TARGET_DIR)/etc/finalsplash.jpg

avr32-bootsplash-dirclean:

ifeq ($(BR2_PACKAGE_AVR32_BOOTSPLASH),y)
TARGETS	+= avr32-bootsplash
endif
