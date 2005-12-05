REVISION=$Revision: 1$
VERSION=$(subst $,,$(subst $Revision: ,,$(REVISION)))
$(warning $(VERSION))
PLUGINS=check_*
DEST_DIR=/usr/lib/nagios/plugins/

all:
	echo $(VERSION) >version

install:
	cp $(PLUGINS) $(DEST_DIR)
