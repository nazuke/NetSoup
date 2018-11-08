all: Projects.class Fetch.class

Projects.class: Projects.java
	javac Projects.java

Fetch.class: Fetch.java
	javac Fetch.java

clean:
	-for FILE in *~ ; do \
		rm $$FILE ; \
	done

distclean: clean
	-for FILE in *.class ; do \
		rm $$FILE ; \
	done
