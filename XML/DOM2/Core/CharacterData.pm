#!/usr/local/bin/perl
#
#   NetSoup::XML::DOM2::Core::CharacterData.pm v00.00.01a 12042000
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


package NetSoup::XML::DOM2::Core::CharacterData;
use strict;
use NetSoup::XML::DOM2::Core::Node;
@NetSoup::XML::DOM2::Core::CharacterData::ISA = qw( NetSoup::XML::DOM2::Core::Node );
my $MODULE = "CharacterData";
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    class | object
  #    hash    {
  #              Key => Value
  #              ..
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $CharacterData = NetSoup::XML::DOM2::Core::CharacterData->new();
  my $CharacterData                = shift;                       # Get element object
  my %args                         = @_;                          # Get arguments
  $CharacterData->SUPER::initialise( %args );                     # Perform base class initialisation
  $CharacterData->{Node}->{Data}   = $args{NodeValue};            # Set character data value
  $CharacterData->{Node}->{Length} = length( $args{NodeValue} );  # Set character data value
  return( $CharacterData );                                       # Return blessed CharacterData object
}


sub data {
  # This method returns the characters of the CharacterData.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    boolean
  # Example:
  #    my $data = $CharacterData->data();
  my $CharacterData = shift;                 # Get element object
  return( $CharacterData->{Node}->{Data} );  # Return CharacterData data
}


sub dataLength {
  # This method returns the length of the CharacterData.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    boolean
  # Example:
  #    my $length = $CharacterData->length();
  my $CharacterData = shift;                   # Get element object
  return( $CharacterData->{Node}->{Length} );  # Return CharacterData length
}


sub substringData {
  # This method returns a range of characters from the CharacterData.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Offset => $offset
  #              Count  => $count
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $CharacterData = $CharacterData->substringData( Offset => $offset, Count => $count );
  my $CharacterData = shift;          # Get element object
  my %args          = @_;             # Get arguments
  my $offset        = $args{Offset};  #
  my $count         = $args{Count};
  my $DOMString     = "";


  return( $DOMString );               # Return DOMString
}


sub appendData {
  # This method appends a sequence of characters to the CharacterData.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Data => $data
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $CharacterData->appendData( Data => $data );
  my $CharacterData                = shift;                                     # Get element object
  my %args                         = @_;                                        # Get arguments
  $CharacterData->{Node}->{Data}  .= $args{Data};                               # Append character data to CharacterData
  $CharacterData->{Node}->{Length} = length( $CharacterData->{Node}->{Data} );  # Recalculate length of CharacterData
  $CharacterData->nodeValue( NodeValue => $CharacterData->{Node}->{Data} );     # Sync Node Value with Data
  return(1);
}


sub insertData {
  # This method inserts a sequence of characters into the CharacterData.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Offset => $offset
  #              Data   => $data
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $CharacterData = $CharacterData->insertData( Offset => $offset, Data => $data );
  my $CharacterData                = shift;                                     # Get element object
  my %args                         = @_;                                        # Get arguments
  my $offset                       = $args{Offset};
  my $data                         = $args{Data};


  $CharacterData->{Node}->{Data}  .= $args{Data};                               # Append character data to CharacterData


  $CharacterData->{Node}->{Length} = length( $CharacterData->{Node}->{Data} );  # Recalculate length of CharacterData
  $CharacterData->nodeValue( NodeValue => $CharacterData->{Node}->{Data} );     # Sync Node Value with Data
  return(1);
}


sub deleteData {
  # This method deletes a range of characters from the CharacterData.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Offset => $offset
  #              Count  => $count
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $CharacterData = $CharacterData->substringData( Offset => $offset, Count => $count );
  my $CharacterData = shift;          # Get element object
  my %args          = @_;             # Get arguments
  my $offset        = $args{Offset};  #
  my $count         = $args{Count};
  my $DOMString     = "";

  $CharacterData->nodeValue( NodeValue => $CharacterData->{Node}->{Data} );     # Sync Node Value with Data
  return(1);
}


sub replaceData {
  # This method replaces a range of characters in the CharacterData.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Offset => $offset
  #              Count  => $count
  #              Data   => $data
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $CharacterData = $CharacterData->replaceData( Offset => $offset, Count => $count, Data => $data );
  my $CharacterData = shift;          # Get CharacterData object
  my %args          = @_;             # Get arguments
  my $offset        = $args{Offset};  #
  my $count         = $args{Count};
  my $data          = $args{Data};
  my $DOMString     = "";

  $CharacterData->nodeValue( NodeValue => $CharacterData->{Node}->{Data} );     # Sync Node Value with Data
  return(1);
}
