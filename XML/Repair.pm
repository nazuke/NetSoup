#!/usr/local/bin/perl
#
#   NetSoup::XML::Repair.pm v00.00.01a 12042000
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


package NetSoup::XML::Repair;
use strict;
use NetSoup::Core;
use NetSoup::XML::Parser;
@NetSoup::XML::Repair::ISA = qw( NetSoup::Core );
1;


sub repair {
  # This private method attempts to repair a defective chunk of XML.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              XML   => \$xml
  #              Tries => 1 .. 256
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Repair  = shift;                        # Get object
  my %args    = @_;                           # Get arguments
  my $XML     = $args{XML};                   # Get array of fault strings
  my $tries   = $args{Tries};                 # Get array of fault strings
  my $success = 0;
  while( $tries ) {
  TRY: for( $Repair->_try( XML => $XML ) ) {  #
      m/^-1$/i && do {                        # Cannot handle error
        $tries = 0;
        last TRY;
      };
      m/^0$/i && do {                         # Error found and fixed
        $tries--;
        last TRY;
      };
      m/^1$/i && do {
        $success++;
        $tries = 0;
        last TRY;
      };
    }
  }
  return( $success );
}


sub _try {
  # This private method attempts to repair a defective chunk of XML.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              XML   => \$xml
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Repair   = shift;                                       # Get object
  my %args     = @_;                                          # Get arguments
  my $XML      = $args{XML};                                  # Get array of fault strings
  my $success  = 0;                                           # Result code
  my $Parser   =  NetSoup::XML::Parser->new();
  my $Document = $Parser->parse( XML        => $XML,          # Attempt to parse XML data
                                 Whitespace => "preserve" );  #
  if( $Parser->flag( Flag => "Error" ) ) {
    my @types   = $Parser->types();                           # Get list of error type codes
    my @samples = $Parser->samples();                         # Get list of faulty symbols
    my $length  = @types - 1;
    for( my $i = 0 ; $i <= $length ; $i++ ) {
    SWITCH: for( $types[$i] ) {

        m/Preprocessor:0005/i && do {                         # Fix "empty" tags
          my $replace = $samples[$i];
          $replace    =~ s:>$:/>:;
          $$XML       =~ s/\Q$samples[$i]\E/$replace/gs;      #
          print( qq(Fixing: "$samples[$i]"\n) );
          print( qq(        "$replace"\n) );
          last SWITCH;
        };

        m/Preprocessor:0006/i && do {                         # Fix tag name case-mismatch
          my $replace = $samples[$i];
          $replace    =~ s:>$:/>:;
          $$XML       =~ s/\Q$samples[$i]\E/$replace/gs;      #
          print( qq(Fixing: "$samples[$i]"\n) );
          print( qq(        "$replace"\n) );
          last SWITCH;
        };

        m//i && do {
          print( qq(Cannot handle "$types[$i]"\n) );          # Cannot handle this error
          $success = -1;
          last SWITCH;
        };

      }
    }
  } else {
    $success++;                                               # The XML data is well formed
  }
  return( $success );
}
