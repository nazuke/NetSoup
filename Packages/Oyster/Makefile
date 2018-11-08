include ../../Makefile.include

test:
	make -C bin test
	-killall -TERM oysterd
	./oysterd -f./oysterd.conf
