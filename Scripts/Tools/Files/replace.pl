#!/usr/local/bin/perl
#
#   NetSoup::Scripts::Tools::Files::replace.pl v00.00.01a 12042000
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


use NetSoup::Files::Directory::Recurse;
use NetSoup::Files::Load;
use NetSoup::Files::Save;


my $files    = NetSoup::Files::Directory::Recurse->new();
my $load     = NetSoup::Files::Load->new();
my $save     = NetSoup::Files::Save->new();
my @list     = <DATA>;
my $callback = sub {
  my $pathname = shift;
  my $data     = "";
  $load->load( Pathname => $pathname, Data => \$data );
  my $count = 0;
  foreach my $line ( @list ) {
    chomp $line;
    next if( length( $line ) == 0 );
    my ( $search, $replace ) = split( /\t/, $line );
    $count += ( $data =~ s/\Q$search\E/$replace/gs );
  }
  $files->debug( "$pathname => $count\n" );
  $save->save( Pathname => $pathname, Data => \$data );
  return(1);
};
$files->startLog();
$files->recurse( Array       => \@ARGV,
                 Recursive   => 1,
                 Directories => 0,
                 Callback    => $callback );
$files->stopLog();
exit(0);


__DATA__
