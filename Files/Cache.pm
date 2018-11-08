#!/usr/local/bin/perl
#
#   NetSoup::Files::Cache.pm v00.00.01g 12042000
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
#   Description: This Perl 5.0 class provides object methods for loading file data.
#
#
#   Methods:
#       load  -  This method loads data from a file into a scalar reference


package NetSoup::Files::Cache;
use strict;
use integer;
use Digest::MD5;
use NetSoup::Files::Load;
use NetSoup::Files::Save;
@NetSoup::Files::Cache::ISA = qw( NetSoup::Files::Load NetSoup::Files::Save );
1;


sub initialise {
  my $Cache     = shift;
  my %args      = @_;
  $Cache->{Age} = $args{Age};
  return( $Cache );
}


sub load_cache {
  my $Cache      = shift;
  my %args       = @_;
  my $Descriptor = $args{Descriptor};
  my $pathname = $Cache->cache_path( Descriptor => $Descriptor );
  my ( $dev,
       $ino,
       $mode,
       $nlink,
       $uid,
       $gid,
       $rdev,
       $size,
       $atime,
       $mtime,
       $ctime,
       $blksize,
       $blocks ) = stat( $pathname );
  if( ( time - $mtime ) > $Cache->{Age} ) {
    return( undef )
  } else {
    return( $Cache->immediate( Pathname => $pathname ) );
  }
  return( undef );
}


sub save_cache {
  my $Cache      = shift;
  my %args       = @_;
  my $Descriptor = $args{Descriptor};
  my $Data       = $args{Data};
  my $Pathname   = $Cache->cache_path( Descriptor => $Descriptor );
  $Cache->buildTree( Pathname => $Pathname );
  if( ! $Cache->save( Pathname => $Pathname, Data => \$Data ) ) {
    return( undef );
  }
  return(1);
}


sub cache_path {
  my $Cache      = shift;
  my %args       = @_;
  my $MD5        = Digest::MD5->new();
  my $Descriptor = $args{Descriptor};
  my $pathname   = "/tmp/NetSoupCache";
  $MD5->add( $Descriptor );
  my @chars      = split( m//, $MD5->hexdigest() );
  while( @chars ) {
    $pathname .= "/" . shift( @chars ) . shift( @chars );
  }
  return( $pathname . "/cache" );
}


sub digest {
  my $Cache = shift;
  my $data  = shift;
  my $MD5   = Digest::MD5->new();
  $MD5->add( $data );
  return( $MD5->hexdigest() );
}
