VERSION=$(subst $,,$(subst $Revision: ,,$Revision: 1$))
$(warning $(VERSION))
PLUGINS=check_*
DEST_DIR=/usr/lib/nagios/plugins/

all:
	echo $(VERSION) >version

install:
	cp $(PLUGINS) $(DEST_DIR)
