#!/usr/local/bin/perl -w

package NetSoup::Mason::Classes::Filters::Jargon::JS;
use strict;
@NetSoup::Mason::Classes::Filters::Jargon::JS::ISA = qw();
my $JavaScript = join( "", <NetSoup::Mason::Classes::Filters::Jargon::JS::DATA> );
1;


sub js {
  my $JS = shift;
  return( $JavaScript );
}


__DATA__
function jgPosPop( id ) {
  var obj = document.getElementById( id );
  obj.style.left    = MouseX + 10 + "px";
  obj.style.top     = MouseY + 10 + "px";
  obj.style.display = "block";
  document.cursor   = "hand";
}

function jgDisPop( id ) {
  document.getElementById( id ).style.display = "none";
}
