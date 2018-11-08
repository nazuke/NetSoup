include ../Makefile.include

# "make pod" generates the HTML format documentation files.
Pod: html
	-rm pod2html-itemcache
	-rm pod2html-dircache

html: *.pod
	for POD in *.pod ; do \
		pod2html $$POD; \
	done;
