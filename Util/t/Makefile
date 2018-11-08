Time: Time.o
	g++ -o Time ../Time.o Time.o

Time.o: Time.cpp
	g++ -O2 -Wall -I../ -c Time.cpp

test: all
	@Time

clean:
	-rm Time.o
	-rm Time
	-rm *~

