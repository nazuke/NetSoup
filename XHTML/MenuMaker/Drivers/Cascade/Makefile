all: CSS.pm JavaScript.pm

CSS.pm: CSS.pm.src MenuMakerStyles.css
	cat CSS.pm.src > CSS.pm
	cat MenuMakerStyles.css >> CSS.pm

JavaScript.pm: JavaScript.pm.src MenuMakerScript.js
	cat JavaScript.pm.src > JavaScript.pm
	cat MenuMakerScript.js >> JavaScript.pm

clean:
	-rm *~
