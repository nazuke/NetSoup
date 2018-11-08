test: stop clean
	hglotd.pl

stop:
	-killall -KILL hglotd.pl

clean:
	-for FILE in *~ ; do rm $$FILE ; done
