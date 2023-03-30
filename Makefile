FILES=README cli.c tcping.h tcping.c Makefile LICENSE
VERNUM=$$(grep TCPING_VERSION tcping.h | cut -d" " -f3 | sed -e 's/"//g')
VER=tcping-$(VERNUM)

CCFLAGS=-Wall
CC=gcc

tcping.linux: tcping.c
	$(CC) -o tcping $(CCFLAGS) cli.c tcping.c

tcping.macos: tcping.linux

tcping.openbsd: tcping.linux

readme: man/tcping.1
	groff -man -Tascii man/tcping.1 | col -bx > README

deb-linux: tcping.linux
	mkdir -p debian/usr/bin
	cp tcping debian/usr/bin
	mkdir -p debian/DEBIAN
	sed -e "s/VERSION/$(VERNUM)/" > debian/DEBIAN/control
	md5sum debian/usr/bin/tcping | sed -e 's#debian/##g' > debian/DEBIAN/md5sums
	dpkg-deb --build debian/ $(VER).deb
	rm -rf debian

.PHONY: clean dist
clean:
	rm -f tcping core *.o

dist:
	mkdir $(VER)
	mkdir $(VER)/man
	cp $(FILES) $(VER)/
	cp man/tcping.1 $(VER)/man/
	tar cvzf $(VER).tar.gz $(VER)
	rm -rf $(VER)
