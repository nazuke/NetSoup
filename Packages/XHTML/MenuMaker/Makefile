all: MenuMaker_Cascade.js # MenuMaker_NS4.html MenuMaker_Sitemap.shtml


test:
	chmod a+x ./MM_Cascade.pl
	./MM_Cascade.pl -iTest.xml -oMenuMaker_Cascade.js -sStylesheet.css


MenuMaker_Cascade.js: MenuMaker.xml
	chmod a+x ./MM_Cascade.pl
	./MM_Cascade.pl -iMenuMaker.xml -oMenuMaker_Cascade.js -sStylesheet.css -c444488 -hDD0000


MenuMaker_NS4.html: MenuMaker.xml
	chmod a+x ./MM_NS4.pl
	-rm MenuMaker_NS4.html
	./MM_NS4.pl -iMenuMaker.xml -oMenuMaker_NS4.html -sStylesheet.css -c444488 -hDD0000


MenuMaker_Hier.shtml: MenuMaker.xml
	chmod a+x ./MM_Hier.pl
	./MM_Hier.pl MenuMaker.xml MenuMaker_Hier.shtml


MenuMaker_Sitemap.shtml: MenuMaker.xml
	chmod a+x ./MM_Sitemap.pl
	./MM_Sitemap.pl MenuMaker.xml MenuMaker_Sitemap.psp


# "make clean" cleans out the intermediate files.
clean:
	for DIR in ./* ; do \
		if( ( test -d $$DIR ) && ( test -e $$DIR/Makefile ) ); then \
			make -C $$DIR clean; \
		fi; \
	done;
	-rm *~
	@sync
