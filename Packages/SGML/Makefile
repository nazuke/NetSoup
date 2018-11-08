# "make clean" cleans out the intermediate files.
clean: *
	for DIR in ./* ; do \
		if( ( test -d $$DIR ) && ( test -e $$DIR/Makefile ) ); then \
			make -C $$DIR clean; \
		fi; \
	done;
	-rm *~
	@sync
