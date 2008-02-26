#############################################################
#
# mplayer
#
#############################################################
MPLAYER_VER:=1.0rc1
MPLAYER_SOURCE:=MPlayer-$(MPLAYER_VER).tar.bz2
MPLAYER_SITE:=http://www7.mplayerhq.hu/MPlayer/releases
MPLAYER_DIR:=$(BUILD_DIR)/MPlayer-$(MPLAYER_VER)
MPLAYER_CAT:=$(BZCAT)
MPLAYER_BINARY:=mplayer
MPLAYER_TARGET_BINARY:=usr/bin/$(MPLAYER_BINARY)

ifeq ($(BR2_ENDIAN),"BIG")
MPLAYER_ENDIAN:=--enable-big-endian
else
MPLAYER_ENDIAN:=--disable-big-endian
endif

ifeq ($(strip $(BR2_PACKAGE_LIBMAD)),y)
MPLAYER_DEP_LIBS:=libmad
MPLAYER_LIB_MAD:=--enable-mad
endif
ifeq ($(strip $(BR2_PACKAGE_FAAD2)),y)
MPLAYER_DEP_LIBS+=faad2
MPLAYER_LIB_FAAD:=--enable-faad-external --disable-faad-internal
else
ifeq ($(strip $(BR2_PACKAGE_MPLAYER_FAAD_INTERNAL_FIXED)),y)
MPLAYER_LIB_FAAD:=--enable-faad-fixed
else
MPLAYER_LIB_FAAD:=--enable-faad
endif
endif

$(DL_DIR)/$(MPLAYER_SOURCE):
	$(WGET) -P $(DL_DIR) $(MPLAYER_SITE)/$(MPLAYER_SOURCE)

$(MPLAYER_DIR)/.unpacked: $(DL_DIR)/$(MPLAYER_SOURCE)
	$(MPLAYER_CAT) $(DL_DIR)/$(MPLAYER_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	toolchain/patch-kernel.sh $(MPLAYER_DIR) package/mplayer/ mplayer-$(MPLAYER_VER)\*.patch\*
	@touch $@

$(MPLAYER_DIR)/.configured: $(MPLAYER_DIR)/.unpacked
	(cd $(MPLAYER_DIR); rm -rf config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
		--prefix=/usr \
		--confdir=/etc \
		--target=$(GNU_TARGET_NAME) \
		--host-cc=$(HOSTCC) \
		--cc=$(TARGET_CC) \
		--as=$(TARGET_CROSS)as \
		--with-extraincdir=$(STAGING_DIR)/include \
		--with-extralibdir=$(STAGING_DIR)/lib \
		$(MPLAYER_LIB_MAD) \
		$(MPLAYER_LIB_FAAD) \
		--enable-fbdev \
		$(MPLAYER_ENDIAN) \
		--disable-mpdvdkit \
		--disable-tv \
		--enable-dynamic-plugins \
	)
	@touch $@

$(MPLAYER_DIR)/$(MPLAYER_BINARY): $(MPLAYER_DIR)/.configured
	$(MAKE) -C $(MPLAYER_DIR)

$(TARGET_DIR)/$(MPLAYER_TARGET_BINARY): $(MPLAYER_DIR)/$(MPLAYER_BINARY)
	$(INSTALL) -m 0755 -D $(MPLAYER_DIR)/$(MPLAYER_BINARY) $(TARGET_DIR)/$(MPLAYER_TARGET_BINARY)
	-$(STRIP) --strip-unneeded $(TARGET_DIR)/$(MPLAYER_TARGET_BINARY)

mplayer: uclibc $(MPLAYER_DEP_LIBS) $(TARGET_DIR)/$(MPLAYER_TARGET_BINARY)

mplayer-clean:
	rm -f $(TARGET_DIR)/$(MPLAYER_TARGET_BINARY)
	-$(MAKE) -C $(MPLAYER_DIR) clean

mplayer-dirclean:
	rm -rf $(MPLAYER_DIR)
#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_MPLAYER)),y)
TARGETS+=mplayer
endif
