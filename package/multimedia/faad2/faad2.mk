#############################################################
#
# faad2
#
#############################################################

FAAD2_VERSION=2.7
FAAD2_SOURCE=faad2-$(FAAD2_VERSION).tar.gz
FAAD2_SITE=http://$(BR2_SOURCEFORGE_MIRROR).dl.sourceforge.net/sourceforge/faac
FAAD2_INSTALL_STAGING=YES
FAAD2_INSTALL_TARGET=YES
FAAD2_AUTORECONF=YES

$(eval $(call AUTOTARGETS,package,faad2))
