REVISION=$Revision$
VERSION=$(strip $(subst $,,$(subst $Revision: ,,$(REVISION))))
PLUGINS=check_*

DIST_FILES=$(PLUGINS) Makefile
DIST_RESULT=nagios-plugins-foton-$(VERSION).tar.gz

DEST_DIR=/usr/lib/nagios/plugins/

all:
	echo $(VERSION) > version

install:
	mkdir -p /usr/lib/nagios/plugins
	cp $(PLUGINS) $(DEST_DIR)

dist:
	tar cfz $(DIST_RESULT) $(DIST_FILES)

clean:
	rm -f version
