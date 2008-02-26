#############################################################
#
# faad2
#
#############################################################

FAAD2_VERSION=2.6.1
FAAD2_SOURCE=faad2-$(FAAD2_VERSION).tar.gz
FAAD2_SITE=http://$(BR2_SOURCEFORGE_MIRROR).dl.sourceforge.net/sourceforge/faac
FAAD2_DIR=$(BUILD_DIR)/faad2
FAAD2_CAT:=$(ZCAT)
FAAD2_BINARY:=libfaad/.libs/libfaad.so
FAAD2_TARGET_BINARY:=usr/lib/libfaad.so

$(DL_DIR)/$(FAAD2_SOURCE):
	$(WGET) -P $(DL_DIR) $(FAAD2_SITE)/$(FAAD2_SOURCE)

$(FAAD2_DIR)/.unpacked: $(DL_DIR)/$(FAAD2_SOURCE)
	$(FAAD2_CAT) $(DL_DIR)/$(FAAD2_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	toolchain/patch-kernel.sh $(FAAD2_DIR) package/faad2/ faad2-$(FAAD2_VERSION)-\*.patch\*
	chmod a+x $(FAAD2_DIR)/configure		\
			$(FAAD2_DIR)/config.sub		\
			$(FAAD2_DIR)/config.guess	\
			$(FAAD2_DIR)/compile		\
			$(FAAD2_DIR)/depcomp		\
			$(FAAD2_DIR)/install-sh		\
			$(FAAD2_DIR)/missing
	$(CONFIG_UPDATE) $(FAAD2_DIR)
	touch $@

$(FAAD2_DIR)/.configured: $(FAAD2_DIR)/.unpacked
	(cd $(FAAD2_DIR); rm -rf config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		$(TARGET_CONFIGURE_ARGS) \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/usr \
		--sysconfdir=/etc \
		$(DISABLE_NLS) \
		$(DISABLE_LARGEFILE) \
	)
	touch $@

$(FAAD2_DIR)/$(FAAD2_BINARY): $(FAAD2_DIR)/.configured
	$(MAKE) -C $(FAAD2_DIR)

$(STAGING_DIR)/$(FAAD2_TARGET_BINARY): $(FAAD2_DIR)/$(FAAD2_BINARY)
	$(MAKE) DESTDIR=$(STAGING_DIR) -C $(FAAD2_DIR) install
	$(SED) "s,^libdir=.*,libdir=\'$(STAGING_DIR)/usr/lib\',g" $(STAGING_DIR)/usr/lib/libfaad.la

$(TARGET_DIR)/$(FAAD2_TARGET_BINARY): $(STAGING_DIR)/$(FAAD2_TARGET_BINARY)
	cp -dpf $(STAGING_DIR)/usr/lib/libfaad*so* $(TARGET_DIR)/usr/lib
	$(STRIP) --strip-unneeded $(TARGET_DIR)/usr/lib/libfaad*so*
ifeq ($(strip $(BR2_PACKAGE_FAAD2_PLAYER)),y)
	cp -dpf $(STAGING_DIR)/usr/bin/faad $(TARGET_DIR)/usr/bin/
	$(STRIP) --strip-unneeded $(TARGET_DIR)/usr/bin/faad
endif

faad2:	uclibc $(TARGET_DIR)/$(FAAD2_TARGET_BINARY)

faad2-source: $(DL_DIR)/$(FAAD2_SOURCE)

faad2-clean:
	-$(MAKE) -C $(FAAD2_DIR) clean

faad2-dirclean:
	rm -rf $(FAAD2_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_FAAD2)),y)
TARGETS+=faad2
endif
