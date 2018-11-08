#!/usr/local/bin/perl
#
#   NetSoup::URL::Escape.pm v00.00.01a 12042000
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
#       initialise  -  This method is the object initialiser
#       ascii2url   -  This method encodes ascii strings using url escapes
#       url2ascii   -  This method converts url-encoded strings to plain ascii data


package NetSoup::URL::Escape;
use NetSoup::Core;
@NetSoup::URL::Escape::ISA = qw( NetSoup::Core );
my @TABLE = ();
foreach my $i ( 0   .. 47,
                58  .. 64,
                91  .. 96,
                123 .. 255 ) {
  my $char   = pack( "C1", $i );
  my @seq    = unpack( "H2", $char );
  $TABLE[$i] = uc( join( "", '%', @seq ) );
}
1;


sub escape {
  my $Escape = shift;
  my %args   = @_;
  my @URL    = split( "", $args{URL} );
  for( my $i = 0 ; $i < @URL ; $i++ ) {
    if( defined $TABLE[ord($URL[$i])] ) {
      $URL[$i] = $TABLE[ord($URL[$i])];
    }
  }
  return( join( "", @URL ) );
}


sub unescape {
  my $Escape = shift;
  my %args   = @_;
  my $URL    = $args{URL};
  for( my $i = 0 ; $i <= 255 ; $i++ ) {
    if( defined $TABLE[$i] ) {
      my $replace = chr($i);
      $URL =~ s/\Q$TABLE[$i]\E/$replace/gs;
    }
  }
  return( $URL );
}
