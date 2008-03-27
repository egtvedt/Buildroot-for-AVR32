ifeq ($(strip $(BR2_PACKAGE_MTD_UTILS)),y)
  include package/mtd/mtd-utils/mtd.mk
else
  ifeq ($(strip $(BR2_PACKAGE_MTD_20061007)),y)
    include package/mtd/20061007/mtd.mk
  else
    ifeq ($(strip $(BR2_PACKAGE_MTD_20050122)),y)
      include package/mtd/20050122/mtd.mk
    else
      ifeq ($(strip $(BR2_PACKAGE_MTD_SNAPSHOT)),y)
        include package/mtd/20050122/mtd.mk
      else
        # If we are generating a JFFS2 root file system, we need mtd-utils.
        ifeq ($(strip $(BR2_TARGET_ROOTFS_JFFS2)),y)
          include package/mtd/mtd-utils/mtd.mk
        endif
      endif
    endif
  endif
endif
