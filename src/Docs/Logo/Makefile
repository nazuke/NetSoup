PUBLISH=../../../Publish

# "make web" makes the web site documentation
web: *
	if ! test -e ${PUBLISH}; then \
		mkdir ${PUBLISH}; \
	fi
	cp *.jpg ${PUBLISH}/

clean:
	rm *~
