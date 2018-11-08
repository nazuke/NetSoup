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
