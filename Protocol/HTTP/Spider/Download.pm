#!/usr/local/bin/perl
#
#   NetSoup::Protocol::HTTP::Spider::Download.pm v00.00.01a 12042000
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
#       download    -  This method performs the download operation


package NetSoup::Protocol::HTTP::Spider::Download;
use strict;
use NetSoup::Core;
use NetSoup::Protocol::HTTP::Spider::Simple;
use NetSoup::URL::Parse;
use NetSoup::Files::Save;
@NetSoup::Protocol::HTTP::Spider::Download::ISA = qw( NetSoup::Core );
my $URLParse = NetSoup::URL::Parse->new();
1;


sub download {
  # This method performs the download operation.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              URL    => $URL
  #              Prefix => $Prefix
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Download = shift;                                                       # Get object
  my %args     = @_;                                                          # Get arguments
  my $Save     = NetSoup::Files::Save->new();                                 # Get new save object
  my $URL      = $args{URL};                                                  # Get URL
  my $prefix   = $args{Prefix} || "./";                                       # Get pathname prefix
  my $Spider   = NetSoup::Protocol::HTTP::Spider::Simple->new( Debug => 1 );  #
  my $callback = sub {
    my %params   = @_;                                                        # Get callback parameters
    my $data     = $params{Document}->body();
    my $pathname = $URLParse->pathname( $params{URL} );
    my $filename = $URLParse->filename( $params{URL} ) || "index.html";
    my $flag     = 0;
    my $recurse  = 0;
    $pathname    =~s:^/:$prefix:;
    $pathname    = $pathname . $filename;
  SWITCH: for( $params{Document}->field( Name => "Content-Type" ) ) {         # Acceptable types
      m|application/x-javascript|i && do {
        $flag++;
        $recurse++;
        last SWITCH;
      };
      m|image/.+|i && do {
        $flag++;
        last SWITCH;
      };
      m|text/.+|i && do {
        $flag++;
        $recurse++;
        last SWITCH;
      };
    }
    if( $flag ) {
      $Save->buildTree( Pathname => $pathname );                              # Build directory structure
      $Save->save( Pathname => $pathname,                                     # Write data to file
                   Data     => \$data );
    }
    return( $recurse );
  };
  $Spider->spider( URL      => $args{URL},
                   Callback => $callback );
  return(1);
}
