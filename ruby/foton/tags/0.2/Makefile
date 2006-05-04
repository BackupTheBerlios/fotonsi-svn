test:
	ruby -w -Ilib test/ts_foton.rb

clean:
	ruby -w setup.rb clean

dist:
	VERSION=`ruby -Ilib -rfoton -e "print Foton::VERSION"`; \
        TMPDIR=tmp.$$$$; \
        DIR=$$TMPDIR/foton-ruby-$$VERSION; \
        mkdir -p $$DIR; \
        while read file; do \
            DEST=$$DIR/`dirname $$file`; \
            mkdir -p $$DEST; \
            if [ -f $$file ]; then cp $$file $$DEST; fi; \
        done < MANIFEST; \
        tar cfz foton-ruby-$$VERSION.tar.gz -C $$TMPDIR foton-ruby-$$VERSION; \
        rm -rf $$TMPDIR

.PHONY: test clean dist
