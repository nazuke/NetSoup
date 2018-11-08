all: Core

Core: Core.o
	g++ -o Core ../Core.o Core.o

Core.o: Core.cpp
	g++ -I../ -O2 -c -o Core.o Core.cpp

install:

test: all
	@./Core

clean:
	-rm *~

distclean: clean
	-rm Core
	-rm *.o

web:
