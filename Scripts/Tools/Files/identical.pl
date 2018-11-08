#!/usr/local/bin/perl
#
#   NetSoup::Scripts::Tools::Files::identical.pl v00.00.01a 12042000
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
#   Description: This Perl 5.0 script locates all identical files under a directory.


use NetSoup::Files::Directory;
use NetSoup::Files::Load;


foreach ( @ARGV ) {
  open( LOG, ">$_.log" );
  my $files    = NetSoup::Files::Directory->new();
  my @left     = ();
  my @right    = ();
  my $callback = sub {
    my $pathname = shift;
    push( @left, $pathname );
    push( @right, $pathname );
    return(1);
  };
  $files->descend( Pathname    => $_,
                   Recursive   => 1,
                   Directories => 0,
                   Callback    => $callback );
 LEFT: foreach ( @left ) {
    my $left = $_;
  RIGHT: foreach ( @right ) {
      my $right = $_;
      next RIGHT if( $left eq $right );
      if( compare( $left, $right ) ) {
        print( STDOUT "$left\t$right\n" );
        print( LOG    "$left\t$right\n" );
      }
    }
    shift( @right );
  }
  close( LOG );
}
exit(0);


sub compare {
  my $left  = shift;
  my $right = shift;
  my $ident = 0;
  my ( $leftExt )  = ( $left  =~ m/(\.[^\.]+)$/i );
  my ( $rightExt ) = ( $right =~ m/(\.[^\.]+)$/i );
  return( $ident ) if( lc( $leftExt ) ne lc( $rightExt ) );
  if( ( -s $left ) == ( -s $right ) ) {
    if( open( LEFT, $left ) ) {
      if( open( RIGHT, $right ) ) {
        my $leftChar  = "";
        my $rightChar = "";
      COMP: while( sysread( LEFT, $leftChar, 1 ) ) {
          sysread( RIGHT, $rightChar, 1 );
          if( $leftChar eq $rightChar ) {
            $ident = 1;
          } else {
            $ident = 0;
            last COMP;
          }
        }
        close( RIGHT );
        close( LEFT );
      }
    }
  }
  return( $ident );
}
