include ../Makefile.include

all: mylib.so

mylib.so: mylib.h mylib.c
	gcc -fPIC -c -I/usr/local/lib/perl5/5.8.0/i686-linux-thread-multi/CORE -o mylib.so mylib.c
