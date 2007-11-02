#############################################################
#
# Build the jffs2 root filesystem image
#
#############################################################

ifneq ($(strip $(BR2_TARGET_ROOTFS_JFFS2_READ_PARTITION_SETUP)),y)
JFFS2_OPTS := --eraseblock=$(strip $(BR2_TARGET_ROOTFS_JFFS2_EBSIZE))

ifeq ($(strip $(BR2_TARGET_ROOTFS_JFFS2_PAD)),y)
ifneq ($(strip $(BR2_TARGET_ROOTFS_JFFS2_PADSIZE)),0x0)
JFFS2_OPTS += --pad=$(strip $(BR2_TARGET_ROOTFS_JFFS2_PADSIZE))
else
JFFS2_OPTS += --pad
endif
endif

ifeq ($(BR2_TARGET_ROOTFS_JFFS2_SQUASH),y)
JFFS2_OPTS += --squash
endif

ifeq ($(BR2_TARGET_ROOTFS_JFFS2_LE),y)
JFFS2_OPTS += --little-endian
endif

ifeq ($(BR2_TARGET_ROOTFS_JFFS2_BE),y)
JFFS2_OPTS += --big-endian
endif

ifneq ($(BR2_TARGET_ROOTFS_JFFS2_DEFAULT_PAGESIZE),y)
JFFS2_OPTS += --pagesize=$(BR2_TARGET_ROOTFS_JFFS2_PAGESIZE)
ifeq ($(BR2_TARGET_ROOTFS_JFFS2_NOCLEANMARKER),y)
JFFS2_OPTS += --no-cleanmarkers
endif
endif

JFFS2_TARGET := $(strip $(subst ",,$(BR2_TARGET_ROOTFS_JFFS2_OUTPUT)))
#"))
JFFS2_DEVFILE = $(strip $(subst ",,$(BR2_TARGET_ROOTFS_JFFS2_DEVFILE)))
#"))
ifneq ($(JFFS2_DEVFILE)$(TARGET_DEVICE_TABLE),)
JFFS2_OPTS += --devtable=$(TARGET_DEVICE_TABLE)
endif

else # BR2_TARGET_ROOTFS_JFFS2_READ_PARTITION_SETUP

ifeq ($(BR2_TARGET_ROOTFS_JFFS2_BE),y)
JFFS2_OPTS := --big-endian
else
JFFS2_OPTS := --little-endian
endif

ifeq ($(BR2_TARGET_ROOTFS_JFFS2_SQUASH),y)
JFFS2_OPTS += --squash
endif

JFFS2_TARGET_MULTI := $(strip $(subst ",,$(BR2_TARGET_ROOTFS_JFFS2_OUTPUT)))
#"))
JFFS2_DEVFILE = $(strip $(subst ",,$(BR2_TARGET_ROOTFS_JFFS2_DEVFILE)))
#"))

endif

#
# mtd-host is a dependency which builds a local copy of mkfs.jffs2 if it is needed.
# the actual build is done from package/mtd/mtd.mk and it sets the
# value of MKFS_JFFS2 to either the previously installed copy or the one
# just built.
#
$(JFFS2_TARGET):
	-@find $(TARGET_DIR) -type f -perm +111 | xargs $(STRIP) 2>/dev/null || true;
	@rm -rf $(TARGET_DIR)/usr/man
	@rm -rf $(TARGET_DIR)/usr/share/man
	@rm -rf $(TARGET_DIR)/usr/info
	@if [ -d $(TARGET_DIR)/usr/share ]; then \
		rmdir -p --ignore-fail-on-non-empty $(TARGET_DIR)/usr/share; \
	fi
	-$(STAGING_DIR)/bin/ldconfig -r $(TARGET_DIR) 2>/dev/null
	# Use fakeroot to pretend all target binaries are owned by root
	rm -f $(STAGING_DIR)/_fakeroot.$(notdir $(JFFS2_TARGET))
	touch $(STAGING_DIR)/.fakeroot.00000
	cat $(STAGING_DIR)/.fakeroot* > $(STAGING_DIR)/_fakeroot.$(notdir $(JFFS2_TARGET))
	echo "chown -R 0:0 $(TARGET_DIR)" >> $(STAGING_DIR)/_fakeroot.$(notdir $(JFFS2_TARGET))
ifneq ($(TARGET_DEVICE_TABLE),)
	# Use fakeroot to pretend to create all needed device nodes
	echo "$(STAGING_DIR)/bin/makedevs -d $(TARGET_DEVICE_TABLE) $(TARGET_DIR)" \
		>> $(STAGING_DIR)/_fakeroot.$(notdir $(JFFS2_TARGET))
endif
	# Use fakeroot so mkfs.jffs2 believes the previous fakery
	echo "$(MKFS_JFFS2) $(JFFS2_OPTS) -d $(TARGET_DIR) -o $(JFFS2_TARGET)" \
		>> $(STAGING_DIR)/_fakeroot.$(notdir $(JFFS2_TARGET))
	chmod a+x $(STAGING_DIR)/_fakeroot.$(notdir $(JFFS2_TARGET))
	$(STAGING_DIR)/usr/bin/fakeroot -- $(STAGING_DIR)/_fakeroot.$(notdir $(JFFS2_TARGET))
	-@rm -f $(STAGING_DIR)/_fakeroot.$(notdir $(JFFS2_TARGET))
	@ls -l $(JFFS2_TARGET)
ifeq ($(BR2_JFFS2_TARGET_SREC),y)
	$(TARGET_CROSS)objcopy -I binary -O srec --adjust-vma 0xa1000000 $(JFFS2_TARGET) $(JFFS2_TARGET).srec
	@ls -l $(JFFS2_TARGET).srec
endif

# Build the JFFS2 partitions
$(JFFS2_TARGET_MULTI):
	@if [ ! -f $(BR2_TARGET_ROOTFS_JFFS2_READ_PARTITION_SETUP_FILE) ]; then		 \
		echo;									 \
		echo "Please specify BR2_TARGET_ROOTFS_JFFS2_READ_PARTITION_SETUP_FILE"; \
		echo "in menuconfig, or else JFFS2 partitions can not be used.";	 \
		echo;									 \
		exit 1;									 \
	fi;
	target/jffs2/make-part-images.sh $(JFFS2_TARGET_MULTI) \
		$(TARGET_DIR) $(STAGING_DIR) \
		$(BR2_TARGET_ROOTFS_JFFS2_READ_PARTITION_SETUP_FILE) \
		$(TARGET_DEVICE_TABLE) $(JFFS2_OPTS)
ifeq ($(BR2_JFFS2_TARGET_SREC),y)
	@for image in $@-*; do \
		$(TARGET_CROSS)objcopy -I binary -O srec --adjust-vma 0xa1000000 $$image $$image.srec; \
		ls -l $$image.srec; \
	done;
endif

JFFS2_COPYTO := $(strip $(subst ",,$(BR2_TARGET_ROOTFS_JFFS2_COPYTO)))
#"))

jffs2root: host-fakeroot makedevs mtd-host $(JFFS2_TARGET) $(JFFS2_TARGET_MULTI)
ifneq ($(JFFS2_COPYTO),)
ifneq ($(JFFS2_TARGET),)
	@cp -f $(JFFS2_TARGET) $(JFFS2_COPYTO)
else
	@cp -f $(JFFS2_TARGET_MULTI)-* $(JFFS2_COPYTO)
endif
endif

jffs2root-source: mtd-host-source

jffs2root-clean: mtd-host-clean
ifneq ($(JFFS2_TARGET),)
	-rm -f $(JFFS2_TARGET)
else
	-rm -f $(JFFS2_TARGET_MULTI)-*
endif

jffs2root-dirclean: mtd-host-dirclean
ifneq ($(JFFS2_TARGET),)
	-rm -f $(JFFS2_TARGET)
else
	-rm -f $(JFFS2_TARGET_MULTI)-*
endif

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_TARGET_ROOTFS_JFFS2)),y)
TARGETS+=jffs2root
endif
