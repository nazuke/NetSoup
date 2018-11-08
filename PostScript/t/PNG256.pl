#!/usr/local/bin/perl -w

use NetSoup::PostScript;

my $PostScript = NetSoup::PostScript->new();
$PostScript->program( Program => join( "", <DATA> ) );
my $PNG = $PostScript->render( Type => "png256", XRes => 72, YRes => 72 );
print( STDOUT $PNG );
exit(0);


__DATA__


/inch 72 def


/box {
  newpath
  /height def
  /width def
  moveto
  width 0 rlineto
  0 height rlineto
  0 width sub 0 rlineto
  0 0 height sub rlineto
  stroke
} def

/xpos 10 def
/ypos 10 def
/width 300 def
/height 100 def
xpos ypos width height box


/plotline {
  newpath
  moveto
  1 1 3 { pop lineto } for
  stroke
} def

/point1x 44 def
/point1y 25 def
/point2x 57 def
/point2y 54 def
/point3x 89 def
/point3y 78 def
point3x point3y point2x point2y point1x point1y 10 10 plotline


showpage
