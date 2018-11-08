#!/usr/local/bin/perl
#
#   NetSoup::Scripts::Tools::Files::search.pl v00.00.01a 12042000
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


my @list = <DATA>;
foreach ( @ARGV ) {
  open( LOG, ">$_.log" );
  my $count    = 0;
  my $files    = NetSoup::Files::Directory->new();
  my $callback = sub {
    my $pathname = shift;
    my $data     = "";
    my $load     = NetSoup::Files::Load->new();
    $load->load( Pathname => $pathname,
                 Data     => \$data );
    foreach ( @list ) {
      chomp;
      if( $data =~ m/$_/is ) {
        line( "$pathname => $_" );
        print( LOG "$pathname => $_\n" );
      }
    }
    $count++;
    return(1);
  };
  $files->descend( Pathname    => $_,
                   Recursive   => 1,
                   Directories => 0,
                   Callback    => $callback );
  line( "$count files processed" );
  print( LOG "$count files processed\n" );
  close( LOG );
}
exit(0);


sub line { print( STDOUT (shift) . "\n" ) }


__DATA__
