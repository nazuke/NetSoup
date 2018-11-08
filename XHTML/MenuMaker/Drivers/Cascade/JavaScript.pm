#!/usr/local/bin/perl
#
#   NetSoup::XHTML::MenuMaker::Drivers::Cascade::JavaScript.pm v00.00.01a 12042000
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


package NetSoup::XHTML::MenuMaker::Drivers::Cascade::JavaScript;
use strict;
use NetSoup::Core;
@NetSoup::XHTML::MenuMaker::Drivers::Cascade::JavaScript::ISA = qw( NetSoup::Core );
my $SCRIPT = join( "", <NetSoup::XHTML::MenuMaker::Drivers::Cascade::JavaScript::DATA> );
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


sub insertids {
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
  foreach my $id ( @_ ) {
    $id = qq('$id');
  }
  my $ids = join( ",", @_ );
  $SCRIPT        =~ s/__IDS__/$ids/gs;
  return(1);
}


__DATA__
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
