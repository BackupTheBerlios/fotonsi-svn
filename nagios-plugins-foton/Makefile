REVISION=$Revision$
VERSION=$(strip $(subst $,,$(subst $Revision: ,,$(REVISION))))
PLUGINS=check_*

DEST_DIR=/usr/lib/nagios/plugins/

all:
	echo $(VERSION) > version

install:
	mkdir -p /usr/lib/nagios/plugins
	cp $(PLUGINS) $(DEST_DIR)

clean:
	rm -f version
