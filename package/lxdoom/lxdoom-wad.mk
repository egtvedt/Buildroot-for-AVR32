#############################################################
#
# lxdoom-wad
#
#############################################################

LXDOOM_WAD_VERSION = 1.8
LXDOOM_WAD_SOURCE = doom-$(LXDOOM_WAD_VERSION).wad.gz
LXDOOM_WAD_SITE = ftp://ftp.idsoftware.com/idstuff/doom/
LXDOOM_WAD_DIR=$(BUILD_DIR)/lxdoom-$(LXDOOM_WAD_VERSION)-wad

$(DL_DIR)/$(LXDOOM_WAD_SOURCE):
	 $(WGET) -P $(DL_DIR) $(LXDOOM_WAD_SITE)/$(LXDOOM_WAD_SOURCE)

$(LXDOOM_WAD_DIR)/.unpacked: $(DL_DIR)/$(LXDOOM_WAD_SOURCE)
	mkdir -p $(LXDOOM_WAD_DIR)
	cp -f $(DL_DIR)/$(LXDOOM_WAD_SOURCE) $(LXDOOM_WAD_DIR)
	gunzip -d $(LXDOOM_WAD_DIR)/$(LXDOOM_WAD_SOURCE)
	touch $@

$(TARGET_DIR)/usr/share/games/doom/doom1.wad: $(LXDOOM_WAD_DIR)/.unpacked
	mkdir -p $(TARGET_DIR)/usr/share/games/doom
	cp -f $(LXDOOM_WAD_DIR)/doom-$(LXDOOM_WAD_VERSION).wad $@

lxdoom-wad: uclibc $(TARGET_DIR)/usr/share/games/doom/doom1.wad

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_LXDOOM_WAD)),y)
TARGETS+=lxdoom-wad
endif

