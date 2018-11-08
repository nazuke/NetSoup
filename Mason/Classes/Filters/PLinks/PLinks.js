var pnkCurrentId = null;
var pnkTimeout   = null;

function pnkPosPop( id ) {
  if( pnkCurrentId != null ) {
    document.getElementById( pnkCurrentId ).style.display = "none";    
  }
  pnkCurrentId      = id;
  var obj           = document.getElementById( id );
  obj.style.left    = MouseX + 6 + "px";
  obj.style.top     = MouseY + 6 + "px";
  obj.style.display = "block";
  document.cursor   = "hand";
  pnkTimeout        = window.setTimeout( 'pnkDisPop("' +  id + '")', 5000 );
}


function pnkPosPop2( id ) {
  window.clearTimeout( pnkTimeout );
  pnkCurrentId      = id;
  var obj           = document.getElementById( id );
  obj.style.display = "block";
  document.cursor   = "hand";
}


function pnkDisPop( id ) {
  pnkCurrentId = null;
  document.getElementById( id ).style.display = "none";
}
