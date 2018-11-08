#!/usr/local/bin/perl -w
#
#   NetSoup::Scripts::Tools::Perl::prettycomments.pl v00.00.01a 12042000
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


foreach $filename ( @ARGV ) {
  if( open( FILE, $filename ) ) {
    my @lines = <FILE>;
    close( FILE );
    my $line = "";
    my $max  = 0;
    foreach $line ( @lines ) {
      chomp( $line );
      my ( $left, $comment, $right ) = ( $line =~ m/(^[^#]+ +)(#)(.+)$/ );
      my $tabs = $line =~ m/\t/g;
      if( ( defined $left ) && ( ( length($left) - ( $tabs * 4 ) ) > $max ) ) {
        $max = length( $left );
      }
    }

    lineout( $max );

    open( OUT, ">$filename~" );
    foreach $line ( @lines ) {
      chomp( $line );
      my ( $left, $comment, $right ) = ( $line =~ m/(^[^#]+ +)(#)(.+)$/ );
      if( defined $left ) {
        my $tabs = $line =~ m/\t/g;
        $line = $left . ( " " x ( $max - ( length($left) + ( $tabs * 4 ) ) ) ) . $comment . $right;
      }
      print( OUT "$line\n" );
    }
    close( OUT );
  }
}


sub lineout { print( (shift) . "\n" ) }
