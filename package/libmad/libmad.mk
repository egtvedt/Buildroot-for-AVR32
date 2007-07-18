#############################################################
#
# libmad
#
#############################################################

LIBMAD_VERSION=0.15.1b
LIBMAD_SOURCE=libmad-$(LIBMAD_VERSION).tar.gz
LIBMAD_SITE=http://$(BR2_SOURCEFORGE_MIRROR).dl.sourceforge.net/sourceforge/mad/
LIBMAD_DIR=$(BUILD_DIR)/libmad-$(LIBMAD_VERSION)
LIBMAD_CAT:=$(ZCAT)

$(DL_DIR)/$(LIBMAD_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBMAD_SITE)/$(LIBMAD_SOURCE)

$(LIBMAD_DIR)/.unpacked: $(DL_DIR)/$(LIBMAD_SOURCE)
	$(LIBMAD_CAT) $(DL_DIR)/$(LIBMAD_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	$(CONFIG_UPDATE) $(LIBMAD_DIR)
	toolchain/patch-kernel.sh $(LIBMAD_DIR) package/libmad/ libmad-$(LIBMAD_VERSION)\*.patch\*
	@touch $@

$(LIBMAD_DIR)/.configured: $(LIBMAD_DIR)/.unpacked
	(cd $(LIBMAD_DIR); rm -rf config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/usr \
		--sysconfdir=/etc \
		--disable-debugging \
		--enable-speed \
		$(DISABLE_NLS) \
	);
	@touch $@

$(LIBMAD_DIR)/libmad.a: $(LIBMAD_DIR)/.configured
	rm -f $@
	$(MAKE) CC=$(TARGET_CC) -C $(LIBMAD_DIR)

$(STAGING_DIR)/lib/libmad.a: $(LIBMAD_DIR)/libmad.a
	$(MAKE) prefix=$(STAGING_DIR)/usr -C $(LIBMAD_DIR) install

$(TARGET_DIR)/usr/lib/libmad.so: $(STAGING_DIR)/lib/libmad.a
	mkdir -p $(TARGET_DIR)/usr/lib
	cp -dpf $(STAGING_DIR)/lib/libmad.so* $(TARGET_DIR)/usr/lib/

libmad:	uclibc $(TARGET_DIR)/usr/lib/libmad.so

libmad-source: $(DL_DIR)/$(LIBMAD_SOURCE)

libmad-clean:
	@if [ -d $(LIBMAD_DIR)/Makefile ] ; then \
		$(MAKE) -C $(LIBMAD_DIR) clean ; \
	fi;

libmad-dirclean:
	rm -rf $(LIBMAD_DIR) $(LIBMAD_DIR)
#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_LIBMAD)),y)
TARGETS+=libmad
endif
