PACKAGE=uclpw
VERSION=$(shell ruby -Ibin -ruclpw -e "print UCLPW::VERSION")
TMPDIR=tmp.dist
DISTNAME=$(PACKAGE)-$(VERSION)

all: doc

doc:
	rdoc README bin/

clean:
	rm -rf doc $(TMPDIR)
	ruby -w setup.rb clean

MANIFEST: clean
	find | egrep -v /.svn >MANIFEST

dist: clean MANIFEST
	mkdir -p $(TMPDIR)/$(DISTNAME)
	while read file; do \
	    dir=`dirname $$file`; \
	    mkdir -p $(TMPDIR)/$(DISTNAME)/$$dir; \
	    [ -f $$file ] && cp $$file $(TMPDIR)/$(DISTNAME)/$$dir; \
	done <MANIFEST
	tar cfz $(DISTNAME).tar.gz -C $(TMPDIR) $(DISTNAME)
	rm -rf $(TMPDIR)

.PHONY: all doc
