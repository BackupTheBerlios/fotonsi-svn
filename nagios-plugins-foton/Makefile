REVISION=$Revision$
VERSION=$(strip $(subst $,,$(subst $Revision: ,,$(REVISION))))
PLUGINS=check_*

DIST_FILES=$(PLUGINS) Makefile
DIST_NAME=nagios-plugins-foton-$(VERSION)
DIST_RESULT=$(DIST_NAME).tar.gz
DIST_TMP_DIR=dist-tmp

DEST_DIR=/usr/lib/nagios/plugins/

all:
	echo $(VERSION) > version

install:
	mkdir -p /usr/lib/nagios/plugins
	cp $(PLUGINS) $(DEST_DIR)

dist:
	mkdir -p $(DIST_TMP_DIR)/$(DIST_NAME)
	cp $(DIST_FILES) $(DIST_TMP_DIR)/$(DIST_NAME)
	tar cfz $(DIST_RESULT) -C $(DIST_TMP_DIR) $(DIST_NAME)
	rm -rf $(DIST_TMP_DIR)

clean:
	rm -f version
