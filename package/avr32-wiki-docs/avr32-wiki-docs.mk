#############################################################
#
# AVR32 Wiki documentation
#
#############################################################
AVR32_WIKI_DOCS_VERSION:=2.0.0
AVR32_WIKI_DOCS_SOURCE:=avr32_linux_user_guide_$(AVR32_WIKI_DOCS_VERSION).tar.gz
AVR32_WIKI_DOCS_SITE:=http://www.atmel.com/dyn/resources/prod_documents
AVR32_WIKI_DOCS_CAT:=$(ZCAT)
AVR32_WIKI_DOCS_DIR:=$(BUILD_DIR)/avr32_linux_user_guide

$(DL_DIR)/$(AVR32_WIKI_DOCS_SOURCE):
	 $(WGET) -P $(DL_DIR) $(AVR32_WIKI_DOCS_SITE)/$(AVR32_WIKI_DOCS_SOURCE)

$(AVR32_WIKI_DOCS_DIR)/.unpacked: $(DL_DIR)/$(AVR32_WIKI_DOCS_SOURCE)
	$(AVR32_WIKI_DOCS_CAT) $(DL_DIR)/$(AVR32_WIKI_DOCS_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	touch $@

$(TARGET_DIR)/www/wiki/index.html: $(AVR32_WIKI_DOCS_DIR)/.unpacked
	mkdir -p $(TARGET_DIR)/www
	cp -dpfr $(AVR32_WIKI_DOCS_DIR)/docs $(TARGET_DIR)/www/wiki
ifeq ($(BR2_PACKAGE_AVR32_WIKI_DOCS_ROOT_INDEX_FILE),y)
	cp -dpfr package/avr32-wiki-docs/index.html $(TARGET_DIR)/www/
endif
	touch $@

avr32-wiki-docs: busybox $(TARGET_DIR)/www/wiki/index.html

avr32-wiki-docs-clean:
	rm -rf $(TARGET_DIR)/www/wiki
ifeq ($(BR2_PACKAGE_AVR32_WIKI_DOCS_ROOT_INDEX_FILE),y)
	rm -f $(TARGET_DIR)/www/index.html
endif

avr32-wiki-docs-dirclean:
	rm -rf $(AVR32_WIKI_DOCS_DIR)

avr32-wiki-docs-source: $(DL_DIR)/$(AVR32_WIKI_DOCS_SOURCE)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_AVR32_WIKI_DOCS)),y)
TARGETS+=avr32-wiki-docs
endif
