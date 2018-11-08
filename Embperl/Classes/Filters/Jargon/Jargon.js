var jgTheBrowser = "";
var jgTheVersion = navigator.appVersion.slice( 0, 1 );

switch ( navigator.appName ) {
 case "Microsoft Internet Explorer" :
   jgTheBrowser = "MSIE";
   break;
 case "Netscape" :
   jgTheBrowser = "Gecko";
   break;
 default :
   jgTheBrowser = "MSIE";
   break;
}

var jgMouseX = 0;
var jgMouseY = 0;

function msieTrackMouse() {
  jgMouseX = window.event.clientX + document.body.scrollLeft;
  jgMouseY = window.event.clientY + document.body.scrollTop;
}

function geckoTrackMouse( e ) {
  jgMouseX = e.pageX;
  jgMouseY = e.pageY;
}

switch ( jgTheBrowser ) {
 case "MSIE" :
   document.onmousemove = msieTrackMouse;
   break;
 case "Gecko" :
   if( jgTheVersion == 4 ) {
     document.captureEvents( Event.MOUSEMOVE );
   }
   document.onmousemove = geckoTrackMouse;
   break;
 default :
   document.onmousemove = msieTrackMouse;
   break;
}

function jgPosPop( id ) {
  var obj = document.getElementById( id );
  obj.style.left    = jgMouseX + 10 + "px";
  obj.style.top     = jgMouseY + 10 + "px";
  obj.style.display = "block";
  document.cursor   = "hand";
}

function jgDisPop( id ) {
  document.getElementById( id ).style.display = "none";
}
