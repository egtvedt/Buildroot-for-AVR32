#############################################################
#
# libts
#
#############################################################
TSLIB_VERSION:=1.0
TSLIB_SOURCE:=tslib-$(TSLIB_VERSION).tar.bz2
TSLIB_SITE:=http://download.berlios.de/tslib
TSLIB_CAT:=$(BZCAT)
TSLIB_DIR:=$(BUILD_DIR)/tslib-$(TSLIB_VERSION)

$(DL_DIR)/$(TSLIB_SOURCE):
	$(WGET) -P $(DL_DIR) $(TSLIB_SITE)/$(TSLIB_SOURCE)

tslib-source: $(DL_DIR)/$(TSLIB_SOURCE)

$(TSLIB_DIR)/.patched: $(DL_DIR)/$(TSLIB_SOURCE)
	$(TSLIB_CAT) $(DL_DIR)/$(TSLIB_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	toolchain/patch-kernel.sh $(TSLIB_DIR) package/tslib/ tslib-$(TSLIB_VERSION)\*.patch\*
	touch $@

$(TSLIB_DIR)/.configured: $(TSLIB_DIR)/.patched
	(cd $(TSLIB_DIR); rm -rf config.cache; \
	./autogen.sh; \
	$(TARGET_CONFIGURE_OPTS) \
	CFLAGS="$(TARGET_CFLAGS) -DUSE_INPUT_API" \
	./configure \
	--target=$(GNU_TARGET_NAME) \
	--host=$(GNU_TARGET_NAME) \
	--build=$(GNU_HOST_NAME) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--datadir=/usr/share \
	--localstatedir=/var \
	--disable-static \
	--disable-linear-h2200 \
	--disable-ucb1x00 \
	--disable-corgi \
	--disable-collie \
	--disable-h3600 \
	--disable-mk712 \
	--disable-arctic2 \
	--enable-input \
	)
	$(SED) 's:rpl\_malloc:malloc:g' $(TSLIB_DIR)/config.h
	touch $@

$(TSLIB_DIR)/.compiled: $(TSLIB_DIR)/.configured
	$(MAKE) -C $(TSLIB_DIR)
	touch $@

$(STAGING_DIR)/usr/lib/libts.so: $(TSLIB_DIR)/.compiled
	$(MAKE) -C $(TSLIB_DIR) DESTDIR=$(STAGING_DIR) install

$(TARGET_DIR)/usr/lib/libts.so: $(STAGING_DIR)/usr/lib/libts.so
	cp -dpf $(STAGING_DIR)/usr/lib/libts*.so* $(TARGET_DIR)/usr/lib/
	-$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(TARGET_DIR)/usr/lib/libts.so*
	-$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(STAGING_DIR)/usr/lib/ts/*.so
	cp -dpf $(STAGING_DIR)/usr/lib/ts/*.so $(TARGET_DIR)/usr/lib/
	cp -dpf $(STAGING_DIR)/usr/bin/ts_calibrate $(TARGET_DIR)/usr/bin/
	-$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(TARGET_DIR)/usr/bin/ts_calibrate
	cp -dpf $(STAGING_DIR)/usr/bin/ts_finddev $(TARGET_DIR)/usr/bin/
	-$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(TARGET_DIR)/usr/bin/ts_finddev
	-$(STRIP) --strip-unneeded $(TARGET_DIR)/usr/bin/inputattach
	-$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(TARGET_DIR)/usr/bin/inputattach
	cp -dpf $(STAGING_DIR)/usr/bin/ts_test $(TARGET_DIR)/usr/bin/
	-$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(TARGET_DIR)/usr/bin/ts_test
	cp -dpf package/tslib/ts.conf $(TARGET_DIR)/etc/

tslib: uclibc $(TARGET_DIR)/usr/lib/libts.so

tslib-build: uclibc $(TSLIB_DIR)/.configured
	rm -f $(TSLIB_DIR)/.compiled
	$(MAKE) -C $(TSLIB_DIR)
	touch $(TSLIB_DIR)/.compiled

tslib-clean:
	$(MAKE) DESTDIR=$(TARGET_DIR) CC=$(TARGET_CC) -C $(TSLIB_DIR) uninstall
	rm -f $(STAGING_DIR)/lib/libts.*
	rm -f $(STAGING_DIR)/usr/lib/libts.*
	-$(MAKE) -C $(TSLIB_DIR) clean

tslib-dirclean:
	rm -rf $(TSLIB_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_TSLIB)),y)
TARGETS+=tslib
endif
