include $(TOPDIR)/rules.mk

PKG_NAME:=serial2mqtt
PKG_VERSION:=0.0
PKG_RELEASE:=3

include $(INCLUDE_DIR)/package.mk

define Package/serial2mqtt
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Gateway between serial devices and MQTT
  URL:=https://github.com/vortex314/serial2mqtt
  DEPENDS:=+libpthread +libstdcpp
endef

define Package/serial2mqtt/description
  A gateway that reads serial port (USB, serial, bluetooth) commands and transfers to MQTT host.
  MQTT without ethernet or Wifi on a low cost micocontroller. Don't develop a serial command interface,
  just use MQTT UI's and features.
endef

define Package/serial2mqtt/conffiles
/etc/serial2mqtt/serial2mqtt.json
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	git clone https://github.com/eclipse/paho.mqtt.c $(PKG_BUILD_DIR)/paho.mqtt.c
	git clone https://github.com/bblanchon/ArduinoJson $(PKG_BUILD_DIR)/ArduinoJson
	git clone https://github.com/vortex314/Common $(PKG_BUILD_DIR)/Common
	git clone https://github.com/vortex314/serial2mqtt $(PKG_BUILD_DIR)/serial2mqtt
	$(Build/Patch)
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/Common -f Common.mk CXX=$(TARGET_CXX) AR=$(TARGET_AR) ArchiveOutputSwitch="r "
	$(MAKE) -C $(PKG_BUILD_DIR)/paho.mqtt.c mkdir build/VersionInfo.h CC=$(TARGET_CC) GAI_LIB=""
	cd $(PKG_BUILD_DIR)/paho.mqtt.c && CC=$(TARGET_CC) AR=$(TARGET_AR) ../serial2mqtt/makePaho.sh
	$(MAKE) -C $(PKG_BUILD_DIR)/serial2mqtt -f serial2mqtt.mk CXX=$(TARGET_CXX) LinkerName=$(TARGET_CXX)
endef

define Package/serial2mqtt/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/serial2mqtt/Debug/serial2mqtt $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/serial2mqtt
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/serial2mqtt/serial2mqtt.json $(1)/etc/serial2mqtt/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/serial2mqtt.init $(1)/etc/init.d/serial2mqtt
endef

$(eval $(call BuildPackage,serial2mqtt))
