# "make web" makes the web site documentation
web: *
	for FILE in * ; do \
		if( test -d $$FILE ) ; then \
			if( test -e $$FILE/Makefile ) ; then \
				make -C $$FILE web ; \
			fi; \
		fi; \
	done

clean:
	rm *~
