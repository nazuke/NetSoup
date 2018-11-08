#!/usr/local/bin/perl
#
#   NetSoup::Scripts::Tools::Files::identicalLog.pl v00.00.01a 12042000
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
#   Description: This Perl 5.0 script processes the log generated by identical.pl.


foreach ( @ARGV ) {
  open( IN, $_ );
  open( OUT, ">$_.out" );
  my $current = "";
  while ( <IN> ) {
    chomp;
    my ( $next ) = ( m/^([^\t]+)\t/ );
    if( ! $current ) { ( $current ) = ( m/^([^\t]+)\t/ ) }
    if( $current eq $next ) {
      my $pad = " " x length( $current );
      s/^([^\t]+)\t/$pad\t/;
    } else {
      $current = $next;
    }
    print( OUT "$_\n" );
  }
  close( OUT );
  close( IN );
  print( "Done $_" );
}
exit(0);
