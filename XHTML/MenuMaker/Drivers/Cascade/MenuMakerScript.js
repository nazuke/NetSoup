var MMtheBrowser = "";
var MMtheVersion = navigator.appVersion.slice( 0, 1 );
var MMStack      = new Array(); // The menu stack

switch ( navigator.appName ) {
 case "Microsoft Internet Explorer" :
   MMtheBrowser = "MSIE";
   break;
 case "Netscape" :
   MMtheBrowser = "MOZILLA";
   break;
 case "Opera" :
   MMtheBrowser = "OPERA";
   break;
 default :
   MMtheBrowser = "MSIE";
   break;
}

function nothing() {}  // "Nothing will come of nothing" - King Lear

function MMsm( level, id ) {
  // This function opens a menu.
  for( var i = level ; i < MMStack.length ; i++ ) {
    MMmc( i );
  }
  switch ( MMtheBrowser ) {
  case "MSIE" :
    if( MMtheVersion <= 4 ) {
      document.all[id].style.display = 'block';
      break;
    }
  default:
    document.getElementById(id).style.display = 'block';
    break;
  }
  MMStack[level] = id;
  return( true );
}

function MMmc( level ) {
  // This functions closes a menu.
  for( var i = level ; i < MMStack.length ; i++ ) {
    if( MMStack[i] ) {
      switch ( MMtheBrowser ) {
      case "MSIE" :
        if( MMtheVersion <= 4 ) {
          document.all[MMStack[i]].style.display = 'none';
          break;
        }
      default:
        document.getElementById(MMStack[i]).style.display = 'none';
        break;
      }
    }
  }
  return( true );
}

function MMcc() {
  // This function closes a cascade of open menus.
  // Attach this function to document elements.
  MMmc( 0 );
  return( true );
}

function MMh( obj ) {
  // This function highlights a menu item.
  obj.style.backgroundColor = "#<!--HILITE-->";
  document.cursor = "hand";
}

function MMl( obj ) {
  // This function de-highlights a menu item.
  obj.style.backgroundColor = "#<!--NORMAL-->";
}

function MMj( url ) {
  window.location = url;
  return( true );
}

function MMspd( id ) {
  // This function shows a Product Description
  var obj = document.getElementById( id );
  obj.style.display = "block";
  return( true );
}

function MMhpd( id ) {
  // This function hides a Product Description
  var obj = document.getElementById( id );
  obj.style.display = "none";
  return( true );
}
