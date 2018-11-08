#!/usr/local/bin/perl
#
#   NetSoup::class.pm v00.00.01a 12042000
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
#       method  -  description


package NetSoup::PostScript;
use strict;
use NetSoup::Core;
use NetSoup::Files::Filenames;
use NetSoup::Files::Save;
@NetSoup::PostScript::ISA = qw( NetSoup::Core );
1;


sub initialise {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Key => Value
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $PostScript         = shift;  # Get object
  my %args               = @_;     # Get arguments
  $PostScript->{Program} = $args{Program} || undef;
  return( $PostScript );
}


sub program {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Key => Value
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $PostScript         = shift;  # Get object
  my %args               = @_;     # Get arguments
  $PostScript->{Program} = $args{Program};
  return( $PostScript );
}


sub render {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Key => Value
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $PostScript = shift;  # Get object
  my %args       = @_;     # Get arguments
  my $type       = $args{Type};
  my $width      = $args{Width};
  my $height     = $args{Height};
  my $XRes       = $args{XRes} || 72;
  my $YRes       = $args{YRes} || 72;
  if( defined $PostScript->{Program} ) {
    my $program  = $PostScript->{Program};
    my $filename = NetSoup::Files::Filenames->new()->unique( Pathname => "/tmp", String => ".ps" );
    if( NetSoup::Files::Save->new()->save( Pathname => $filename, Data => \$program ) ) {
      my $result = `/usr/bin/gs -g${width}x${height} -r${XRes}x${YRes} -sDEVICE=$type -dNOPAUSE -sOutputFile=- -q $filename`;
      unlink( $filename );
      return( $result );
    } else {
      print( STDERR "Error\n" );
    }
  }
  return( undef );
}
