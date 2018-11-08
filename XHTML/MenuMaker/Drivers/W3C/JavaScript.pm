#!/usr/local/bin/perl
#
#   NetSoup::XHTML::MenuMaker::Drivers::W3C::JavaScript.pm v00.00.01a 12042000
#
#   Copyright (C) 2000  Jason Holland <jason.holland@dial.pipex.com>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#
#   Description: This Perl 5.0 class provides object methods for.
#
#
#   Methods:
#       code  -  This method returns the JavaScript text


package NetSoup::XHTML::MenuMaker::Drivers::W3C::JavaScript;
use strict;
use NetSoup::Core;
@NetSoup::XHTML::MenuMaker::Drivers::W3C::JavaScript::ISA = qw( NetSoup::Core );
my $SCRIPT = join( "", <NetSoup::XHTML::MenuMaker::Drivers::W3C::JavaScript::DATA> );
1;

sub script {
  # This method returns the JavaScript text.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $JavaScript = shift;  # Get object
  my %args       = @_;     # Get arguments
  return( $SCRIPT );
}


__DATA__
var MMtheBrowser = "";
var MMtheVersion = navigator.appVersion.slice( 0, 1 );
var currentMM1   = "";  // Change current menu scheme to stack-based,
var currentMM2   = "";  // thereby allowing infinite number of menus
var currentMM3   = "";
var currentMM4   = "";
var currentMM5   = "";
var currentColor = "";

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

var MM_MouseX = 0;
var MM_MouseY = 0;

function mozTrackMouse( e ) {
    MM_MouseX = e.pageX;
    MM_MouseY = e.pageY;
    //window.status = "MOUSEMOVE " + MM_MouseX + " " + MM_MouseY;
}

function msieTrackMouse() {
    MM_MouseX = window.event.clientX;
    MM_MouseY = window.event.clientY;
    //window.status = "MOUSEMOVE " + MM_MouseX + " " + MM_MouseY;
}

switch ( MMtheBrowser ) {
case "MSIE" :                                       // Encompasses MSIE 4 and later
    document.onmousemove = msieTrackMouse;
    break;
case "MOZILLA" :                                    // Encompasses Netscape 4, Netscape 6 and Mozilla
    if( MMtheVersion == 4 ) {
        document.captureEvents( Event.MOUSEMOVE );  // Capture mouse movements for NS4
    }
    document.onmousemove = mozTrackMouse;
    break;
case "OPERA" :                                      // Some nutters seem to prefer this browser...
    document.onmousemove = msieTrackMouse;
    break;
default :
    document.onmousemove = msieTrackMouse;
    break;
}

function MMcollapse() {
    if( currentMM2 )
        hm2( currentMM2 );
}

function sm1(id) {
    if( currentMM2 )
        hm2( currentMM2 );
    currentMM1 = id;
    showMenu(id);
}

function sm2(id) {
    if( currentMM2 )
        hm2( currentMM2 );
    currentMM2 = id;
    showMenu(id);
}

function sm3(id) {
    if( currentMM3 )
        hm3( currentMM3 );
    currentMM3 = id;
    showMenu(id);
}

function sm4(id) {
    if( currentMM4 )
        hm4( currentMM4 );
    currentMM4 = id;
    showMenu(id);
}

function sm5(id) {
    if( currentMM5 )
        hm5( currentMM5 );
    currentMM5 = id;
    showMenu(id);
}


function hm1(id) {
    if( currentMM2 )
        hm2( currentMM2 );
    hideMenu(id);
}

function hm2(id) {
    if( currentMM3 )
        hm3( currentMM3 );
    if( currentMM2 )
        hideMenu(id);
}

function hm3(id) {
    if( currentMM4 )
        hm4( currentMM4 );
    if( currentMM3 )
        hideMenu(id);
}

function hm4(id) {
    if( currentMM5 )
        hm5( currentMM5 );
    if( currentMM4 )
        hideMenu(id);
}

function hm5(id) {
    if( currentMM5 )
        hideMenu(id);
}

function showMenu(id) {
    var Y_OFFSET = 2;
    var X_OFFSET = 8;
    switch ( MMtheBrowser ) {
    case "MSIE" :
        if( MMtheVersion >= 4 ) {
            document.all[id].style.top        = MM_MouseY + "px";
            document.all[id].style.left       = MM_MouseX + "px";
            //document.all[id].style.visibility = "visible";
            document.all[id].style.display = "block";
        } else if( MMtheVersion >= 5 ) {
            document.getElementById(id).style.top        = MM_MouseY + 4 + "px";
            document.getElementById(id).style.left       = MM_MouseX + 4 + "px";
            //document.getElementById(id).style.visibility = "visible";
            document.getElementById(id).style.display = "block";
        }
        break;
    case "MOZILLA" :
        if( MMtheVersion == 4 ) {
            document.layers[id].top        = MM_MouseY + Y_OFFSET;
            document.layers[id].left       = MM_MouseX + X_OFFSET;
            document.layers[id].visibility = "show";
        } else if( MMtheVersion >= 5 ) {
            document.getElementById(id).style.top        = MM_MouseY + Y_OFFSET + "px";
            document.getElementById(id).style.left       = MM_MouseX + X_OFFSET + "px";
            //document.getElementById(id).style.visibility = "visible";
            document.getElementById(id).style.display = "block";
        }
        break;
    case "OPERA" :
        document.getElementById(id).style.top        = MM_MouseY + "px";
        document.getElementById(id).style.left       = MM_MouseX + "px";
        document.getElementById(id).style.visibility = "visible";
        break;
    default :
        break;
    }
}

function hideMenu(id) {
    switch ( MMtheBrowser ) {
    case "MSIE" :
        if( MMtheVersion >= 4 ) {
            //document.all[id].style.visibility = "hidden";
            document.all[id].style.display = "none";
        } else if( MMtheVersion >= 5 ) {
            //document.getElementById(id).style.visibility = "hidden";
            document.getElementById(id).style.display = "none";
        }
        break;
    case "MOZILLA" :
        if( MMtheVersion == 4 ) {
            document.layers[id].visibility = "hide";
        } else if( MMtheVersion >= 5 ) {
            //document.getElementById(id).style.visibility = "hidden";
            document.getElementById(id).style.display = "none";
        }
        break;
    case "OPERA" :
        document.getElementById(id).style.visibility = "hidden";
        break;
    default :
        break;
    }
}

function MMj( url ) {
    if( url != "javascript:MMnv()" )
        document.location = url;
}

function MMhc( element ) {
    // Higlight Button Colour
    currentColor                  = element.style.backgroundColor;
    element.style.backgroundColor = "#BB2222";
}

function MMrc( element ) {
    // Restore Button Colour
    element.style.backgroundColor = currentColor;
}

function MMnv() {} // "Nothing will come of nothing" - King Lear
