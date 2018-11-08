#!/usr/local/bin/perl -w

package NetSoup::Mason::Classes::JS::Public;
use strict;
@NetSoup::Mason::Classes::JS::Public::ISA = qw();
my $JavaScript = join( "", <NetSoup::Mason::Classes::JS::Public::DATA> );
1;


sub js {
  my $JS = shift;
  return( $JavaScript );
}


__DATA__
var TheBrowser = "";
var TheVersion = navigator.appVersion.slice( 0, 1 );

switch ( navigator.appName ) {
 case "Microsoft Internet Explorer" :
   TheBrowser = "MSIE";
   break;
 case "Netscape" :
   TheBrowser = "Gecko";
   break;
 default :
   TheBrowser = "MSIE";
   break;
}

var MouseX = 0;
var MouseY = 0;

function msieTrackMouse() {
  MouseX = window.event.clientX + document.body.scrollLeft;
  MouseY = window.event.clientY + document.body.scrollTop;
}

function geckoTrackMouse( e ) {
  MouseX = e.pageX;
  MouseY = e.pageY;
}

switch ( TheBrowser ) {
 case "MSIE" :
   document.onmousemove = msieTrackMouse;
   break;
 case "Gecko" :
   if( TheVersion == 4 ) {
     document.captureEvents( Event.MOUSEMOVE );
   }
   document.onmousemove = geckoTrackMouse;
   break;
 default :
   document.onmousemove = msieTrackMouse;
   break;
}
