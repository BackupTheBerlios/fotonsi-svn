DIST_BASE_NAME=newchrb

all: rdoc

rdoc:
	rdoc bin README lib/ data/newchrb/

test:
	RUBYLIB=lib:data/newchrb:test/lib ruby -w test/ts_newchrb.rb

clean:
	ruby -w setup.rb clean

MANIFEST: clean
	find | egrep -v /.svn >MANIFEST

dist: MANIFEST
	VERSION=`ruby -Ilib -rnewchrb -e "print NewChrb::VERSION"`; \
	TMPDIR=tmp.$$$$; \
	DIR=$$TMPDIR/$(DIST_BASE_NAME)-$$VERSION; \
	mkdir -p $$DIR; \
	while read file; do \
	    DEST=$$DIR/`dirname $$file`; \
	    mkdir -p $$DEST; \
	    if [ -f $$file ]; then cp $$file $$DEST; fi; \
	done < MANIFEST; \
	tar cfz $(DIST_BASE_NAME)-$$VERSION.tar.gz -C $$TMPDIR $(DIST_BASE_NAME)-$$VERSION; \
	rm -rf $$TMPDIR

.PHONY: test rdoc clean dist
