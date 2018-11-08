/*
    menu.java v00.00.01a 12042000

    Copyright (C) 2000  Jason Holland <jason.holland@dial.pipex.com>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


    Description: This JavaScript is used by the Html Editor menu system.
*/


import parent.HyperGlotEdit.serialEdit ;    // Import definitions from external sources
import parent.HyperGlotEdit.store ;         // Import definitions from external sources


var serialMenu = 0;                          // Initialise serial number
var serverName = "dial.pipex.com";           // Global stores working web server hostname


function getPage( url ) {
  // This method fetches a page and loads it into the display frame.
  var display = new String( "http://" + serverName + "/cgi-bin/HyperGlot/hGetPut.cgi?function=fetch&url="   + url );  //
  var editor  = new String( "http://" + serverName + "/cgi-bin/HyperGlot/hGetPut.cgi?function=extract&url=" + url );  //
  parent.HyperGlotDisplay.location = display;                                                                         // Update display window location
  parent.HyperGlotEdit.location    = editor;                                                                          // Update editor window location
  incSerialNo();                                                                                                       // Synchronise serial numbers
}


function storePage( url ) {
	// This method inserts the strings into the Html document.
	if( syncSerialNo() == true ) {                                  // Check serial number synchronicity
		store( url );                                               // Call method in editor frame script
	} else {
		alert( "The serial numbers are no longer synchronised!" );  // Display alert message
	}
	return true;
}


function incSerialNo() {
  // This method creates a new serial number
  var number = serialMenu + 1;
  serialMenu = number;
  serialEdit = number;
  return number;
}


function syncSerialNo() {
  // This method checks all serial numbers for synchronicity.
  if( serialMenu == serialEdit ) {  // Compare serial numbers
	return true;
  } else {
	return false;
  }
}


export getPage ;
