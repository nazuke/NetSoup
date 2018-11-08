include ../Makefile.include

all: clean cleanutil Time.o
	make -C t

Time.o: Time.cpp
	g++ -O2 -Wall -I../ -c Time.cpp

install:

test: all
	make -C t test

cleanutil:
	-rm Time.o
	make -C t clean

web:
