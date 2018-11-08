all: clean
	for FILE in * ; do \
		if( test -d $$FILE ) ; then \
			if( test -e $$FILE/Makefile ) ; then \
				make -C $$FILE ; \
			fi; \
		fi; \
	done
	make HyperGlot.class

HyperGlot.class: HyperGlot.java
	javac HyperGlot.java

test: all
	java HyperGlot

clean:
	-for FILE in *~ ; do \
		rm $$FILE ; \
	done
	make -C hyperglot clean

distclean: clean
	-for FILE in *.class ; do \
		rm $$FILE ; \
	done
	make -C hyperglot distclean
