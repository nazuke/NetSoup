include ../../../Makefile.include

all: clean htdocs

htdocs: clean *.*html *.xml
	MM_Cascade.pl -iMenu.xml -oMenu.js -sMenu.css
	-rm -r          /usr/local/apache/vhosts/rattlehead/htdocs/NetSoup/Framework
	mkdir          /usr/local/apache/vhosts/rattlehead/htdocs/NetSoup/Framework
	cp *html       /usr/local/apache/vhosts/rattlehead/htdocs/NetSoup/Framework/
	cp -r includes /usr/local/apache/vhosts/rattlehead/htdocs/NetSoup/Framework/
	cp -r lists    /usr/local/apache/vhosts/rattlehead/htdocs/NetSoup/Framework/
	cp *.js        /usr/local/apache/vhosts/rattlehead/htdocs/NetSoup/Framework/
