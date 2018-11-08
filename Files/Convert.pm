#!/usr/local/bin/perl
#
#   NetSoup::Files::Convert.pm v00.00.01a 12042000
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
#       initialise  -  This method is the object initialiser for this class


package NetSoup::Files::Convert;
use strict;
use NetSoup::Files::Directory;
use NetSoup::Files::Load;
use NetSoup::Files::Save;
@NetSoup::Files::Convert::ISA = qw( NetSoup::Files::Directory );
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    Convert
  #    hash    {
  #              Verbose  => 0 | 1
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $Convert = NetSoup::Files::Convert->new();
  my $Convert         = shift;                # Get Convert object
  my %args            = @_;                   # Get arguments
  $Convert->{Verbose} = $args{Verbose} || 0;  # Get verbose switch
  return( $Convert );
}


sub convert {
  # This method converts files and directories.
  # Calls:
  #    none
  # Parameters Required:
  #    Convert
  #    hash    {
  #              Pathname => $pathname
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $Convert->convert( Pathname => $pathname );
  my $Convert   = shift;                                                # Get Convert object
  my %args      = @_;                                                   # Get arguments
  my $Pathname  = $args{Pathname};
  my $Directory = NetSoup::Files::Directory->new();
  my $Load      = NetSoup::Files::Load->new();
  my $Save      = NetSoup::Files::Save->new();
  if( -d $Pathname ) {
    $Directory->descend( Pathname  => $Pathname,
                         Recursive => 1,
                         Callback  => sub {
                           my $pathname = shift;
                           $Convert->convert( Pathname => $pathname );  #
                         } );
  } elsif( -f $Pathname ) {
    my $Data = "";
    if( $^O =~ m/mac/i ) {
      return(1) if( MacPerl::GetFileInfo( $Pathname ) ne "TEXT" );
    }
    print( qq(Converting "$Pathname"\n) ) if( $Convert->{Verbose} );
    $Load->load( Pathname => $Pathname,
                 Data     => \$Data );
    $Convert->_normalize( Data => \$Data );
    $Convert->_convert( Data => \$Data );
    $Save->save( Pathname => $Pathname,
                 Data     => \$Data );
    if( $^O =~ m/mac/i ) {
      MacPerl::SetFileInfo( 'R*ch', "TEXT", $Pathname );
    }
  }
  return(1);
}


sub _normalize {
  # This private method prepares the text data.
  # Calls:
  #    none
  # Parameters Required:
  #    Convert
  #    hash    {
  #              Data => \$Data
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $Convert->_normalize( Data => \$Data );
  my $Convert = shift;                             # Get Parser
  my %args    = @_;                                # Get arguments
  my $Data    = $args{Data};
  $$Data      =~ s/([\x0D][\x0A]|[\x0D])/\x0A/gs;  # Normalize line endings to Unix \n format
  return(1);
}


sub _convert {
  # This private method should be overridden.
  # Calls:
  #    none
  # Parameters Required:
  #    Convert
  #    hash    {
  #              Data => \$Data
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $Convert->_convert( Data => \$Data );
  my $Convert = shift;        # Get Convert object
  my %args    = @_;           # Get arguments
  my $Data    = $args{Data};  # Get text data
  return(1);
}
