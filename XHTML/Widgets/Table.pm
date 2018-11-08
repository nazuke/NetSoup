#!/usr/local/bin/perl
#
#   NetSoup::XHTML::Widgets::Table.pm v00.00.01b 12042000
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
#   Description: This Perl 5.0 class generates XHTML Table widgets.
#
#
#   Methods:
#       initialise  -  This method is the object initialiser for this class
#       createRow   -  This method creates a table row and returns an Element object


package NetSoup::XHTML::Widgets::Table;
use strict;
use NetSoup::XHTML::Widgets::Serialise;
use NetSoup::XML::DOM2::Core::Element;
use NetSoup::XML::DOM2::Core::Text;
@NetSoup::XHTML::Widgets::Table::ISA = qw( NetSoup::XHTML::Widgets::Serialise );
my $ELEMENT = "NetSoup::XML::DOM2::Core::Element";
my $TEXT    = "NetSoup::XML::DOM2::Core::Text";
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Attributes => \%attributes
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Table        = shift;                                                # Get Table object
  my %args         = @_;                                                   # Get arguments
  my $attributes   = $args{Attributes} || {};                              # Get attributes hash reference
  $Table->{Widget} = $ELEMENT->new( NodeName => "table" );                 # Create new Table element
  foreach my $attribute ( sort keys %{$attributes} ) {                     # Set Table attributes
    $Table->{Widget}->setAttribute( Name  => $attribute,                   # Set Element attributes
                                    Value => $attributes->{$attribute} );
  }
  return( $Table );
}


sub createRow {
  # This method creates a table row and returns an Element object.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Cells => \@cells
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Table = shift;                                                        # Get Table object
  my %args  = @_;                                                           # Get arguments
  my @cells = @{$args{Cells}};
  my $Row   = $ELEMENT->new( NodeName => "tr" );                            # Create new Row element
  foreach my $value ( @cells ) {                                            # Set Table attributes
    my $Cell = $ELEMENT->new( NodeName => "td" );                           # Create new Row element
    if( ref $value ) {                                                      # Check for blessed reference
      $Cell->appendChild( NewChild => $value );                             # Append an XML Node
    } else {
      $Cell->appendChild( NewChild => $TEXT->new( NodeValue => $value ) );  # Append Text Node
    }
    $Row->appendChild( NewChild => $Cell );                                 # Append Cell to Row
  }
  $Table->{Widget}->appendChild( NewChild => $Row );                        # Append Row to Table
  return( $Row );
}


sub getWidget {
  # This method returns the widget as a DOM2 object.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Table = shift;           # Get Table object
  my %args  = @_;              # Get arguments
  return( $Table->{Widget} );
}
