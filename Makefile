SYSCONF_DIR := /etc
INIT_DIR := init.d
INSTALL_DIR := /usr/sbin

all:

install:
	mkdir -p $(DESTDIR)/$(SYSCONF_DIR)/wifish
	mkdir -p $(DESTDIR)/$(SYSCONF_DIR)/wifish/networks
	mkdir -p $(DESTDIR)/$(INSTALL_DIR)/
	cp ressources/wifish.conf $(DESTDIR)/$(SYSCONF_DIR)/wifish/
	cp ressources/init/wifishd $(DESTDIR)/$(SYSCONF_DIR)/$(INIT_DIR)/wifishd
	cp -r ressources/templates $(DESTDIR)/$(SYSCONF_DIR)/wifish/
	chmod 644 $(DESTDIR)/$(SYSCONF_DIR)/wifish/wifish.conf
	chmod 644 $(DESTDIR)/$(SYSCONF_DIR)/wifish/templates/*
	cat src/wifish-common.sh src/wifish-cfg.sh > $(DESTDIR)/$(INSTALL_DIR)/wifish-cfg
	cat src/wifish-common.sh src/wifishd.sh > $(DESTDIR)/$(INSTALL_DIR)/wifishd
	cp src/wifish $(DESTDIR)/$(INSTALL_DIR)/wifish
	sed -i "s|^DEFAULT_CONFIG_FILE.*|DEFAULT_CONFIG_FILE='$(SYSCONF_DIR)/wifish/wifish.conf'|" $(DESTDIR)/$(INSTALL_DIR)/wifish-cfg $(DESTDIR)/$(INSTALL_DIR)/wifishd $(DESTDIR)/$(SYSCONF_DIR)/$(INIT_DIR)/wifishd
	sed -i "s|^TEMPLATES_DIR.*|TEMPLATES_DIR='$(SYSCONF_DIR)/wifish/templates/'|" $(DESTDIR)/$(SYSCONF_DIR)/wifish/wifish.conf
	sed -i "s|^USER_NETWORK_DIR.*|USER_NETWORK_DIR='$(SYSCONF_DIR)/wifish/networks/'|" $(DESTDIR)/$(SYSCONF_DIR)/wifish/wifish.conf
	chmod 755 $(DESTDIR)/$(INSTALL_DIR)/wifish-cfg $(DESTDIR)/$(INSTALL_DIR)/wifishd $(DESTDIR)/$(INSTALL_DIR)/wifish $(DESTDIR)/$(SYSCONF_DIR)/$(INIT_DIR)/wifishd

