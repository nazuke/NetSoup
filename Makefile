#   Copyright (C) 2000  Jason Holland <jason.holland@dial.pipex.com>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#
#   Description: This is the Makefile for the NetSoup modules.

include Makefile.include

# "make all" sets the file modes for the scripts and
# modules, and also rebuilds the documentation files.
all: clean modes C++
	for FILE in * ; do \
		if( test -d $$FILE ) ; then \
			if( test -e $$FILE/Makefile ) ; then \
				make -C $$FILE ; \
			fi; \
		fi; \
	done
	@sync
	@echo "Now run \"make install\" to install NetSoup"

# "make modes" sets the files modes for the scripts and modules.
modes:
	@chmod -R ug+wr .
	@chmod a+x configure
	@chmod a+x src/*
	@find ./ -regex ".*\.p.?" -exec chmod a+x {} \;
	@find ./ -regex ".*\.cgi" -exec chmod a+x {} \;

# "make html" generates the Html format documentation files.
html: pod/*.html */pod/*.html */*/pod/*.html */*/*/pod/*.html */*/*/*/pod/*.html
	find . -name "pod2html-itemcache" -exec rm {} \;
	find . -name "pod2html-dircache"  -exec rm {} \;

pod/*.html: pod/*.pod
	find ./pod           -name "*.pod" -exec perl src/makedocs BUILD_FILE {} \;

*/pod/*.html: */pod/*.pod
	find ./*/pod         -name "*.pod" -exec perl src/makedocs BUILD_FILE {} \;

*/*/pod/*.html: */*/pod/*.pod
	find ./*/*/pod       -name "*.pod" -exec perl src/makedocs BUILD_FILE {} \;

*/*/*/pod/*.html: */*/*/pod/*.pod
	find ./*/*/*/pod     -name "*.pod" -exec perl src/makedocs BUILD_FILE {} \;

*/*/*/*/pod/*.html: */*/*/*/pod/*.pod
	find ./*/*/*/*/pod   -name "*.pod" -exec perl src/makedocs BUILD_FILE {} \;

# "make test" verifies that NetSoup is installed and recognised by Perl.
test:
	@echo "You should see a positive message next..."
	@perl -e 'use NetSoup::Core; my $$core = NetSoup::Core->new(); \
	$$core->debug("If you can read this then NetSoup is installed!");'

# "make distclean" clears out all intermediate and configuration files.
distclean: clean distclean++
	find . -name "*.pod" -exec src/makedocs CLEAN_FILE {} \;
	@sync

#############################################################################
#                                                                           #
#    C++ Targets                                                            #
#                                                                           #
#    These targets are for C++ compilation, currently experimental.         #
#                                                                           #
#############################################################################

# "make C++" builds all C++ targets.
C++: Core.o

Core.o: Core.hpp Core.cpp
	g++ -O2 -c Core.cpp

# "make test" runs all of the C++ test programs.
test++: C++
	make -C t test++

# "make clean++" removes all compiled C++ files.
distclean++:
	if( test -e *.o ) ; then \
		rm *.o ; \
	fi;

#############################################################################
#                                                                           #
#    Development Targets                                                    #
#                                                                           #
#    These targets are for development use only, and                        #
#    should not normally be invoked by end users.                           #
#                                                                           #
#############################################################################

GETDATE=$(shell date +%Y%m%d) # Store current date
NOW=$(strip ${GETDATE} )

# Makes backups
backup:
	make dist
	cp ./Publish/NetSoup-${NOW}.tar.gz ../Backups/

# "make dist" prepares the NetSoup package for distribution.
dist: clean modes
	-rm -rf ./Publish
	-rm ../NetSoup.tar ../NetSoup.tar.gz ../NetSoup-*.tar.gz
	tar --directory=../ -cf ../NetSoup-${NOW}.tar NetSoup
	gzip -9 ../NetSoup-${NOW}.tar
	mkdir ./Publish
	mv ../NetSoup-${NOW}.tar.gz ./Publish/

# "make check" performs a syntax check of all scripts and modules.
check:
	@echo "Checking Perl scripts and modules..."
	find . -regex ".+\.p[lm]" -exec perl src/check {} \;
	@echo "Checking Perl CGI scripts..."
	find . -regex ".+\.cgi"   -exec perl src/check {} \;
