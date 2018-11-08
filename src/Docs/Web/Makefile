PUBLISH=../../../Publish

# "make web" makes the web site documentation
web: *
	if ! test -e ${PUBLISH}; then \
		mkdir ${PUBLISH}; \
	fi
	cp content.shtml ${PUBLISH}/
	cp sidebar.shtml ${PUBLISH}/

clean:
	rm *~
