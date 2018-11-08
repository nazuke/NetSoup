document.write('<style type=\"text/css\">div.MMShell, span.MMph {\n font-family: Verdana,sans-serif;\n font-size: 8pt;\n}\ndiv.MMShell {\n position: absolute;\n top: 0px;\n left: 0px;\n}\ntd.MMph, span.MMph {\n visibility: hidden;\n}\ntable.MMc {\n display: block;\n margin-bottom: 0px;\n margin-left: 0px;\n margin-right: 0px;\n margin-top: 0px;\n padding-bottom: 0px;\n padding-left: 0px;\n padding-right: 0px;\n padding-top: 0px;\n}\ntable.MMh {\n margin-bottom: 0px;\n margin-left: 0px;\n margin-right: 0px;\n margin-top: 0px;\n padding-bottom: 0px;\n padding-left: 0px;\n padding-right: 0px;\n padding-top: 0px;\n}\ntable.MMm1, table.MMm2, table.MMm3, table.MMm4, table.MMm5, table.MMm6, table.MMm7, table.MMm8, table.MMm9 {\n display: none;\n margin-bottom: 0px;\n margin-left: 0px;\n margin-right: 0px;\n margin-top: 0px;\n padding-bottom: 0px;\n padding-left: 0px;\n padding-right: 0px;\n padding-top: 0px;\n}\ntd.MMc, td.MMph, .MMpd {\n font-family: Verdana,sans-serif;\n font-size: 8pt;\n height: 20px;\n padding-bottom: 4px;\n padding-left: 8px;\n padding-right: 8px;\n padding-top: 4px;\n vertical-align: top;\n}\ntd.MMc, td.MMph {\n color: #FFFFFF;\n background-color: #444488;\n border-style: solid;\n border-width: 1px;\n border-top-color: #000000;\n border-left-color: #000000;\n border-right-color: #000000;\n border-bottom-color: #000022;\n cursor: hand;\n}\n.MMpd {\n height: 23px;\n}\n</style>')

var theHTML = new String('<div class="MMShell"><table border="0" class="MMc" cellpadding="0" cellspacing="0"><tr><td class="MMc" valign="top" onMouseOver="MMh(this);MMsm(1,\'MM1\');" onMouseOut="MMl(this);">Menu</td></tr></table><table cellspacing="0" class="MMh" cellpadding="0" border="0" onClick="MMcc();"><tr><td valign="top"><table cellspacing="0" class="MMh" cellpadding="0" border="0" onClick="MMcc();"><tr><td valign="top"><table border="0" id="MM1" class="MMm1" cellpadding="0" cellspacing="0"><tr><td class="MMc" valign="top" onMouseOver="MMh(this);MMsm(2,\'MM2\');" onMouseOut="MMl(this);">Item&nbsp;One</td></tr><tr><td class="MMc" valign="top" onMouseOver="MMh(this);MMmc(2);" onMouseOut="MMl(this);" onClick="MMj(\'\')">Item&nbsp;Two</td></tr><tr><td class="MMc" valign="top" onMouseOver="MMh(this);MMmc(2);" onMouseOut="MMl(this);" onClick="MMj(\'\')">Item&nbsp;Three</td></tr></table></td><td valign="top"><table cellspacing="0" class="MMh" cellpadding="0" border="0" onClick="MMcc();"><tr><td valign="top"><table border="0" id="MM2" class="MMm2" cellpadding="0" cellspacing="0"><tr><td class="MMc" valign="top" onMouseOver="MMh(this);MMmc(3);" onMouseOut="MMl(this);" onClick="MMj(\'?c1=Content\')">Test&nbsp;Content</td></tr><tr><td class="MMc" valign="top" onMouseOver="MMh(this);MMmc(3);" onMouseOut="MMl(this);" onClick="MMj(\'?c1=TreeView\')">TreeView&nbsp;Widgets&nbsp;in&nbsp;Content</td></tr><tr><td class="MMc" valign="top" onMouseOver="MMh(this);MMmc(3);" onMouseOut="MMl(this);" onClick="MMj(\'?c1=SQL\')">SQL&nbsp;Table</td></tr><tr><td class="MMc" valign="top" onMouseOver="MMh(this);MMmc(3);" onMouseOut="MMl(this);" onClick="MMj(\'?c1=c4\')">Test&nbsp;Content</td></tr></table></td></tr><tr /></table></td></tr><tr /></table></td></tr><tr><td class="MMph" onClick="MMcc();" valign="top"><span class="MMph">Menu</span></td></tr></table></div>');
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
		obj.style.backgroundColor = "#C10729";
}

function MMl(obj) {
		// This function de-highlights a menu item.
		obj.style.backgroundColor = "#444488";
}

function MMj( url ) {
		window.location = url;
		return( true );
}

