#############################################################
#
# AVR32 Web start
#
#############################################################
AVR32_WEB_START_VERSION:=2.1.0
AVR32_WEB_START_SOURCE:=package/avr32-web-start/files
AVR32_WEB_START_TARGET:=index.html
AVR32_WEB_START_BOARDNAME:=$(shell echo "$(strip $(BR2_BOARD_NAME))" | tr "[:lower:]" "[:upper:]")

$(AVR32_WEB_START_SOURCE)/$(AVR32_WEB_START_TARGET):

$(PROJECT_BUILD_DIR)/.avr32_web_start_installed: $(AVR32_WEB_START_SOURCE)/$(AVR32_WEB_START_TARGET)
	mkdir -p $(TARGET_DIR)/www
	cp -dpf $(AVR32_WEB_START_SOURCE)/index.html $(TARGET_DIR)/www/
	cp -dpf $(AVR32_WEB_START_SOURCE)/avr32_web_start.css $(TARGET_DIR)/www/
	cp -rdpf $(AVR32_WEB_START_SOURCE)/images $(TARGET_DIR)/www/
	$(SED) 's/\%BOARDNAME\%/$(AVR32_WEB_START_BOARDNAME)/' $(TARGET_DIR)/www/$(AVR32_WEB_START_TARGET)
ifneq ($(strip $(BR2_PACKAGE_AVR32_WEB_START_GPIO)),y)
	$(SED) 's/\%GPIO_ENABLED_BEGIN\% -->/GPIO_DISABLED/' $(TARGET_DIR)/www/$(AVR32_WEB_START_TARGET)
	$(SED) 's/<!-- \%GPIO_ENABLED_END\%/GPIO_DISABLED/' $(TARGET_DIR)/www/$(AVR32_WEB_START_TARGET)
else
	mkdir -p $(TARGET_DIR)/www/src
	cp -rdpf $(AVR32_WEB_START_SOURCE)/cgi-bin $(TARGET_DIR)/www/
	ln -sf ../cgi-bin/gpio.sh $(TARGET_DIR)/www/src/gpio.sh
	ln -sf ../cgi-bin/gpio-trigger.sh $(TARGET_DIR)/www/src/gpio-trigger.sh
endif
ifneq ($(strip $(BR2_PACKAGE_SAMBA_SWAT)),y)
	$(SED) 's/\%SWAT_ENABLED_BEGIN\% -->/SWAT_DISABLED/' $(TARGET_DIR)/www/$(AVR32_WEB_START_TARGET)
	$(SED) 's/<!-- \%SWAT_ENABLED_END\%/SWAT_DISABLED/' $(TARGET_DIR)/www/$(AVR32_WEB_START_TARGET)
endif
	ln -sf $(AVR32_WEB_START_TARGET) $(TARGET_DIR)/www/index.asp
	touch $@

avr32-web-start: busybox $(PROJECT_BUILD_DIR)/.avr32_web_start_installed

avr32-web-start-clean:
	rm -f $(TARGET_DIR)/www/$(AVR32_WEB_START_TARGET)
	rm -f $(TARGET_DIR)/www/index.asp

avr32-web-start-dirclean:

avr32-web-start-source: $(AVR32_WEB_START_SOURCE)/$(AVR32_WEB_START_TARGET)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_AVR32_WEB_START)),y)
TARGETS+=avr32-web-start
endif
