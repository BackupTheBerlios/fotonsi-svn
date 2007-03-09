DESTDIR=
CCFLAGS=-g -Wall
CC=gcc
PREFIX=$(DESTDIR)/usr/local

all: libchrb.so.1

chrb.o: chrb.c
	$(CC) -fPIC -rdynamic $(CCFLAGS) -c chrb.c

libchrb.so.1: chrb.o
	$(CC) -shared -Wl,-soname,libchrb.so.1 -o $@ $< -lc -ldl

install: libchrb.so.1
	mkdir -p $(PREFIX)/lib
	cp -u libchrb.so.1 $(PREFIX)/lib

clean:
	rm -f chrb.o libchrb.so.1

.PHONY: all install clean
