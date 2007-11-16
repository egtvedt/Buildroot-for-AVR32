#############################################################
#
# freetype
#
#############################################################
FREETYPE_VERSION:=2.3.5
FREETYPE_SOURCE:=freetype-$(FREETYPE_VERSION).tar.bz2
FREETYPE_SITE:=http://$(BR2_SOURCEFORGE_MIRROR).dl.sourceforge.net/sourceforge/freetype
FREETYPE_CAT:=$(BZCAT)
FREETYPE_DIR:=$(BUILD_DIR)/freetype-$(FREETYPE_VERSION)
FREETYPE_DIR1:=$(TOOL_BUILD_DIR)/freetype-$(FREETYPE_VERSION)
FREETYPE_HOST_DIR:=$(TOOL_BUILD_DIR)/freetype-$(FREETYPE_VERSION)-host

$(DL_DIR)/$(FREETYPE_SOURCE):
	$(WGET) -P $(DL_DIR) $(FREETYPE_SITE)/$(FREETYPE_SOURCE)

freetype-source: $(DL_DIR)/$(FREETYPE_SOURCE)

$(FREETYPE_DIR)/.unpacked: $(DL_DIR)/$(FREETYPE_SOURCE)
	$(FREETYPE_CAT) $(DL_DIR)/$(FREETYPE_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	$(CONFIG_UPDATE) $(FREETYPE_DIR)/builds/unix
	touch $@

# freetype for the target
$(FREETYPE_DIR)/.configured: $(FREETYPE_DIR)/.unpacked
	(cd $(FREETYPE_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		$(TARGET_CONFIGURE_ARGS) \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/usr \
		--libexecdir=/usr/lib \
		--sysconfdir=/etc \
		--localstatedir=/var \
	)
	touch $@

$(FREETYPE_DIR)/.compiled: $(FREETYPE_DIR)/.configured
	$(MAKE) CCexe="$(HOSTCC)" -C $(FREETYPE_DIR)
	touch $@

$(STAGING_DIR)/usr/lib/libfreetype.so: $(FREETYPE_DIR)/.compiled
	$(MAKE) DESTDIR=$(STAGING_DIR) -C $(FREETYPE_DIR) install
	$(SED) "s,^libdir=.*,libdir=\'$(STAGING_DIR)/lib\',g" $(STAGING_DIR)/usr/lib/libfreetype.la
	$(SED) "s,^prefix=.*,prefix=\'$(STAGING_DIR)\',g" \
		-e "s,^exec_prefix=.*,exec_prefix=\'$(STAGING_DIR)/usr\',g" \
		-e "s,^includedir=.*,includedir=\'$(STAGING_DIR)/include\',g" \
		-e "s,^libdir=.*,libdir=\'$(STAGING_DIR)/lib\',g" \
		$(STAGING_DIR)/usr/bin/freetype-config
	touch -c $@

$(TARGET_DIR)/usr/lib/libfreetype.so: $(STAGING_DIR)/usr/lib/libfreetype.so
	cp -dpf $(STAGING_DIR)/usr/lib/libfreetype.so* $(TARGET_DIR)/usr/lib/
	-$(STRIP) --strip-unneeded $(TARGET_DIR)/usr/lib/libfreetype.so

# freetype for the host, needed for build-tools of fontconfig

# great, it can't be built out of tree reliably
$(FREETYPE_DIR1)/.unpacked: $(DL_DIR)/$(FREETYPE_SOURCE)
	$(FREETYPE_CAT) $(DL_DIR)/$(FREETYPE_SOURCE) | tar -C $(TOOL_BUILD_DIR) $(TAR_OPTIONS) -
	$(CONFIG_UPDATE) $(FREETYPE_DIR1)/builds/unix
	touch $@

$(FREETYPE_DIR1)/.configured: $(FREETYPE_DIR1)/.unpacked
	(cd $(FREETYPE_DIR1); \
	./configure \
		CC="$(HOSTCC)" \
		--prefix="$(FREETYPE_HOST_DIR)" \
	)
	touch $@

$(FREETYPE_DIR1)/.compiled: $(FREETYPE_DIR1)/.configured
	$(MAKE) CCexe="$(HOSTCC)" -C $(FREETYPE_DIR1)
	touch $@

$(FREETYPE_HOST_DIR)/lib/libfreetype.so: $(FREETYPE_DIR1)/.configured
	$(MAKE) -C $(FREETYPE_DIR1) install
	touch -c $@

host-freetype: $(FREETYPE_HOST_DIR)/lib/libfreetype.so

freetype: uclibc pkgconfig $(TARGET_DIR)/usr/lib/libfreetype.so

freetype-clean:
	$(MAKE) DESTDIR=$(TARGET_DIR) CC=$(TARGET_CC) -C $(FREETYPE_DIR) uninstall
	-$(MAKE) -C $(FREETYPE_DIR) clean

freetype-dirclean:
	rm -rf $(FREETYPE_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_FREETYPE)),y)
TARGETS+=freetype
endif
