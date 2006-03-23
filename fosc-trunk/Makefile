all: rdoc

rdoc:
	rdoc bin README INSTALL lib/ data/fosc/plugins/

test:
	# Variable de entorno en vez de opción, por si se ejecuta el fosc
	# desde dentro de alguna de las pruebas
	RUBYLIB=lib:data/fosc ruby -w test/ts_fosc.rb

clean:
	ruby -w setup.rb clean

MANIFEST: clean
	find | egrep -v /.svn >MANIFEST

dist: MANIFEST
	VERSION=`ruby -Ilib -rfosc -e "print Fosc::VERSION"`; \
	TMPDIR=tmp.$$$$; \
	DIR=$$TMPDIR/fosc-$$VERSION; \
	mkdir -p $$DIR; \
	while read file; do \
	    DEST=$$DIR/`dirname $$file`; \
	    mkdir -p $$DEST; \
	    if [ -f $$file ]; then cp $$file $$DEST; fi; \
	done < MANIFEST; \
	tar cfz fosc-$$VERSION.tar.gz -C $$TMPDIR fosc-$$VERSION; \
	rm -rf $$TMPDIR

.PHONY: test rdoc
