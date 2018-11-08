/*
    store.java v00.00.01a 12042000

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


    Description: This JavaScript submits the translated form contents to the server.
*/


export serialEdit , store ;  // Export definitions


var serialEdit = 0;          // Global serial number synchronises scripts


function store() {
  // This method submits the form data to the server.
  var formObj = top.HyperGlotEdit.document.magicForm;  // Grab entire form
  return formObj.submit();                             // Submit form data
}


function magicRestore() {
  // This method puts the magic box strings into the correct form fields.
  // Need to check for MacOS in future.
  var formObj = top.HyperGlotEdit.document.magicForm;                           // Grab entire form
  var raw     = new String( formObj.magicText.value );                          // Get magic box string
  var lines   = raw.split( /\r?\n/ );                                           // Split at line endings
  if( lines[lines.length-1].length == 0 ) lines.pop();                          // Pop off blank line
  RESTORE : for( var i = 0 ; i <= ( lines.length - 1 ) ; i++ ) {                // Iterate over array
		var line     = new String( lines[i] );                                      // Create new stirng from array line
		var pair     = line.split( /\t/ );                                          // Split on tab character
		var tokenKey = new String( "!!" + formObj.token.value + "::" + i + "!!" );  // Calculate token value
		if( formObj[tokenKey].value == pair[0] ) {                                  // Check field value against original string
			formObj[tokenKey].value = pair[1];                                        // Insert array value into field
		} else {
			alert( "String mismatch!\r\n\r\nRestore already executed?" );             // Display informative error message
			break RESTORE;                                                            // Break on error
		}
  }
  return true;
}
