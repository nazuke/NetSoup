document.write('<style type=\"text/css\">div.MMShell, span.MMph {\n font-family: Verdana,sans-serif;\n font-size: 8pt;\n}\ndiv.MMShell {\n position: absolute;\n top: 0px;\n left: 0px;\n}\ntd.MMph, span.MMph {\n visibility: hidden;\n}\ntable.MMc {\n display: block;\n margin-bottom: 0px;\n margin-left: 0px;\n margin-right: 0px;\n margin-top: 0px;\n padding-bottom: 0px;\n padding-left: 0px;\n padding-right: 0px;\n padding-top: 0px;\n}\ntable.MMh {\n margin-bottom: 0px;\n margin-left: 0px;\n margin-right: 0px;\n margin-top: 0px;\n padding-bottom: 0px;\n padding-left: 0px;\n padding-right: 0px;\n padding-top: 0px;\n}\ntable.MMm1, table.MMm2, table.MMm3, table.MMm4, table.MMm5, table.MMm6, table.MMm7, table.MMm8, table.MMm9 {\n display: none;\n margin-bottom: 0px;\n margin-left: 0px;\n margin-right: 0px;\n margin-top: 0px;\n padding-bottom: 0px;\n padding-left: 0px;\n padding-right: 0px;\n padding-top: 0px;\n}\ntd.MMc, td.MMph, .MMpd {\n font-family: Verdana,sans-serif;\n font-size: 8pt;\n height: 20px;\n padding-bottom: 4px;\n padding-left: 8px;\n padding-right: 8px;\n padding-top: 4px;\n vertical-align: top;\n}\ntd.MMc, td.MMph {\n color: #FFFFFF;\n background-color: #444488;\n border-style: solid;\n border-width: 1px;\n border-top-color: #666688;\n border-left-color: #666688;\n border-right-color: #000000;\n border-bottom-color: #000022;\n cursor: hand;\n}\n.MMpd {\n height: 23px;\n}\n</style>')

var theHTML = new String('<div 7="MMShell"><table 6="0" 7="MMc" 4="0" 5="0"><tr><td 7="MMc" 8="top" 1="MMh(x);MMsm(1,\'MM1\');" 2="MMl(x);">Menu</td><td 7="MMc" 8="top" 1="MMh(x);MMsm(1,\'MM2\');" 2="MMl(x);">Menu&nbsp;2</td></tr></table><table 5="0" 7="MMh" 4="0" 6="0" 3="MMcc();"><tr><td 8="top"><table 5="0" 7="MMh" 4="0" 6="0" 3="MMcc();"><tr><td 8="top"><table 6="0" id="MM1" 7="MMm1" 4="0" 5="0"><tr><td 7="MMc" 8="top" 1="MMh(x);MMmc(2);" 2="MMl(x);" 3="MMj(\'?c=/PSP/t/content\')">Home</td></tr><tr><td 7="MMc" 8="top" 1="MMh(x);MMmc(2);" 2="MMl(x);" 3="MMj(\'?c=/PSP/Press/Archives/2002/index.psp\')">Press&nbsp;Archives</td></tr><tr><td 7="MMc" 8="top" 1="MMh(x);MMmc(2);" 2="MMl(x);" 3="MMj(\'?c=/PSP/t/customers\')">Customers</td></tr><tr><td 7="MMc" 8="top" 1="MMh(x);MMmc(2);" 2="MMl(x);" 3="MMj(\'?c=/PSP/Index/t/Tree\')">Tree</td></tr></table></td></tr><tr /></table></td><td 8="top"><table 5="0" 7="MMh" 4="0" 6="0" 3="MMcc();"><tr><td 8="top"><table 6="0" id="MM2" 7="MMm1" 4="0" 5="0"><tr><td 7="MMc" 8="top" 1="MMh(x);MMmc(2);" 2="MMl(x);" 3="MMj(\'?c=/PSP/t/groovy\')">Groovy</td></tr></table></td></tr><tr /></table></td></tr><tr><td 7="MMph" 3="MMcc();" 8="top"><span 7="MMph">Menu</span></td><td 7="MMph" 3="MMcc();" 8="top"><span 7="MMph">Menu&nbsp;2</span></td></tr></table></div>');
theHTML = new String(theHTML.replace(/ 1=/g," onMouseOver="));
theHTML = new String(theHTML.replace(/ 2=/g," onMouseOut="));
theHTML = new String(theHTML.replace(/ 3=/g," onClick="));
theHTML = new String(theHTML.replace(/ 4=/g," cellpadding="));
theHTML = new String(theHTML.replace(/ 5=/g," cellspacing="));
theHTML = new String(theHTML.replace(/ 6=/g," border="));
theHTML = new String(theHTML.replace(/ 7=/g," class="));
theHTML = new String(theHTML.replace(/ 8=/g," valign="));
theHTML = new String(theHTML.replace(/\(x\)/g,"(this)"));
document.write(theHTML);
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

function MMh(obj) {
  // This function highlights a menu item.
  obj.style.backgroundColor = "#DD0000";
  document.cursor = "hand";
}

function MMl(obj) {
  // This function de-highlights a menu item.
  obj.style.backgroundColor = "#444488";
}

function MMj( url ) {
  window.location = url;
  return( true );
}

