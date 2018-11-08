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
#   Description: This is the Makefile for the NetSoup Packages.

PUBLISH=../Publish

# "make all" executes the Makefile for each Package.
all:
	for DIR in ./* ; do \
		if( ( test -d $$DIR ) && ( test -e $$DIR/Makefile ) ); then \
			make -C $$DIR; \
		fi; \
	done;
	@sync

# "make install" installs the NetSoup packages.
install:
	for DIR in ./* ; do \
		if( ( test -d $$DIR ) && ( test -e $$DIR/Makefile ) ); then \
			make -C $$DIR install; \
		fi; \
	done;
	@sync

# "make clean" cleans out the intermediate files.
clean:
	-rm *~
	for DIR in ./* ; do \
		if( ( test -d $$DIR ) && ( test -e $$DIR/Makefile ) ); then \
			make -C $$DIR clean; \
		fi; \
	done;
	if test -e ${PUBLISH}; then rm -rf ${PUBLISH}; fi
	@sync

#############################################################################
#    Development Targets                                                    #
#############################################################################

# "make web" makes the web site documentation
web: *
	if ! test -e ${PUBLISH}; then \
		mkdir ${PUBLISH}; \
		mkdir ${PUBLISH}/pkgs; \
	fi
	make -C ./HyperGlot web
