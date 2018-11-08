PUBLISH=../../Publish/pkgs/HyperGlot
STYLES=../docs/Web/styles.css

# "make all" compiles all Java source.
all:
	make JAVA
	@sync

# "make clean" deletes all automatically generated files.
clean:
	-for FILE in *~ ; do rm $$FILE ; done
	-for FILE in * ; do \
		if( test -d $$FILE ) ; then \
			make -C $$FILE clean ; \
		fi; \
	done
	if test -e ${PUBLISH}; then rm -rf ${PUBLISH}; fi
	sync

# "make install" installs the HyperGlot package.
install:
	perl ./build/installer

#############################################################################
#    Development Targets                                                    #
#############################################################################

# "make java" compiles the Java classes.
JAVA:
	make -C java

# "make web" generates the web site directory.
web:
	if( ! test -e ${PUBLISH} ) ; then \
		mkdir ${PUBLISH} ; \
	fi
	cp -r ../../Packages/HyperGlot/docs/Web/*  ${PUBLISH}/
	cp -r ../../Packages/HyperGlot/docs/Logo/* ${PUBLISH}/
	cp ${STYLES} ${PUBLISH}/
