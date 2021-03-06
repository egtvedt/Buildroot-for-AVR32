#############################################################
#
# ipsec-tools
#
#############################################################

IPSEC_TOOLS_VERSION = 0.7.3
IPSEC_TOOLS_SOURCE = ipsec-tools-$(IPSEC_TOOLS_VERSION).tar.bz2
IPSEC_TOOLS_SITE = http://ftp.sunet.se/pub/NetBSD/misc/ipsec-tools/0.7/
IPSEC_TOOLS_INSTALL_STAGING = YES
IPSEC_TOOLS_DEPENDENCIES = openssl flex host-flex

# configure hardcodes -Werror, so override CFLAGS on make invocation
IPSEC_TOOLS_MAKE_OPT = CFLAGS='$(TARGET_CFLAGS)'

IPSEC_TOOLS_CONF_OPT = \
	  --disable-hybrid \
	  --without-libpam \
	  --disable-gssapi \
	  --with-kernel-headers=$(STAGING_DIR)/usr/include

ifeq ($(BR2_PACKAGE_IPSEC_TOOLS_ADMINPORT), y)
IPSEC_TOOLS_CONF_OPT+= --enable-adminport
else
IPSEC_TOOLS_CONF_OPT+= --disable-adminport
endif

ifeq ($(BR2_PACKAGE_IPSEC_TOOLS_NATT), y)
IPSEC_TOOLS_CONF_OPT+= --enable-natt
else
IPSEC_TOOLS_CONF_OPT+= --disable-natt
endif

ifeq ($(BR2_PACKAGE_IPSEC_TOOLS_FRAG), y)
IPSEC_TOOLS_CONF_OPT+= --enable-frag
else
IPSEC_TOOLS_CONF_OPT+= --disable-frag
endif

ifeq ($(BR2_PACKAGE_IPSEC_TOOLS_STATS), y)
IPSEC_TOOLS_CONF_OPT+= --enable-stats
else
IPSEC_TOOLS_CONF_OPT+= --disable-stats
endif

ifeq ($(BR2_INET_IPV6),y)
IPSEC_TOOLS_CONF_OPT+= --enable-ipv6
else
IPSEC_TOOLS_CONF_OPT+= --disable-ipv6
endif

ifneq ($(BR2_PACKAGE_IPSEC_TOOLS_READLINE), y)
IPSEC_TOOLS_CONF_OPT+= --without-readline
else
IPSEC_DEPENDENCIES += readline
endif

ifeq ($(BR2_PACKAGE_IPSEC_SECCTX_DISABLE),y)
IPSEC_TOOLS_CONF_OPT+= --enable-security-context=no
endif
ifeq ($(BR2_PACKAGE_IPSEC_SECCTX_ENABLE),y)
IPSEC_TOOLS_CONF_OPT+= --enable-security-context=yes
endif
ifeq ($(BR2_PACKAGE_IPSEC_SECCTX_KERNEL),y)
IPSEC_TOOLS_CONF_OPT+= --enable-security-context=kernel
endif

$(eval $(call AUTOTARGETS,package,ipsec-tools))
