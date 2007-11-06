#############################################################
#
# popt
#
#############################################################
POPT_VERSION	:= 1.10.4
POPT_DIR	:= $(BUILD_DIR)/popt-$(POPT_VERSION)
POPT_SITE	:= http://rpm.net.in/mirror/rpm-4.4.x
POPT_SOURCE	:= popt-$(POPT_VERSION).tar.gz
POPT_CAT	:= $(ZCAT)
POPT_BINARY	:= libpopt.a

$(DL_DIR)/$(POPT_SOURCE):
	$(WGET) -P $(DL_DIR) $(POPT_SITE)/$(POPT_SOURCE)

popt-source: $(DL_DIR)/$(POPT_SOURCE)

$(POPT_DIR)/.unpacked: $(DL_DIR)/$(POPT_SOURCE)
	$(POPT_CAT) $(DL_DIR)/$(POPT_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	toolchain/patch-kernel.sh $(POPT_DIR) package/popt/ \*.patch*
	$(CONFIG_UPDATE) $(POPT_DIR)
	touch $@

$(POPT_DIR)/.configured: $(POPT_DIR)/.unpacked
	(cd $(POPT_DIR); rm -f config.cache;			\
		$(TARGET_CONFIGURE_OPTS)			\
		$(TARGET_CONFIGURE_ARGS)			\
		./configure					\
			--target=$(GNU_TARGET_NAME)		\
			--host=$(GNU_TARGET_NAME)		\
			--build=$(GNU_HOST_NAME)		\
			--prefix=/usr				\
			--sysconfdir=/etc			\
			--localstatedir=/var			\
			--includedir=/include			\
			--enable-shared				\
			--enable-static				\
			$(DISABLE_NLS)				\
	);
	touch $@

$(POPT_DIR)/.libs/$(POPT_BINARY): $(POPT_DIR)/.configured
	$(MAKE) CC=$(TARGET_CC) -C $(POPT_DIR)
	touch -c $@

$(STAGING_DIR)/lib/$(POPT_BINARY): $(POPT_DIR)/.libs/$(POPT_BINARY)
	$(MAKE) DESTDIR=$(STAGING_DIR) -C $(POPT_DIR) install
	$(SED) "s,^libdir=.*,libdir=\'$(STAGING_DIR)/lib\',g" $(STAGING_DIR)/lib/libpopt.la

$(TARGET_DIR)/lib/libpopt.so.0.0.0: $(STAGING_DIR)/lib/$(POPT_BINARY)
	cp -a $(STAGING_DIR)/lib/libpopt.so $(TARGET_DIR)/lib/
	cp -a $(STAGING_DIR)/lib/libpopt.so.0* $(TARGET_DIR)/lib/
	$(STRIP) --strip-unneeded $(TARGET_DIR)/lib/libpopt.so.0.*
	touch -c $@

popt: uclibc $(TARGET_DIR)/lib/libpopt.so.0.0.0

popt-clean:
	rm -f $(TARGET_DIR)/lib/libpopt*
	-$(MAKE) -C $(POPT_DIR) clean

popt-dirclean:
	rm -rf $(POPT_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_POPT)),y)
TARGETS		+= popt
endif
