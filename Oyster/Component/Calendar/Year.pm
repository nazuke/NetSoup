#!/usr/local/bin/perl
#
#   NetSoup::Oyster::Component::Calendar::Year.pm v00.00.01a 12042000
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


package NetSoup::Oyster::Component::Calendar::Year;
use strict;
use NetSoup::Oyster::Component::Calendar::Month;
use NetSoup::Oyster::Component;
use NetSoup::XHTML::Widgets::Table::text2table;
use NetSoup::XML::DOM2::Core::Document;
use NetSoup::XML::DOM2::Traversal::Serialise;
use NetSoup::XML::DOM2::Traversal::TreeWalker;
@NetSoup::Oyster::Component::Calendar::Year::ISA = qw( NetSoup::Oyster::Component );
my $DOCUMENT   = "NetSoup::XML::DOM2::Core::Document";
my $SERIALISE  = "NetSoup::XML::DOM2::Traversal::Serialise";
my $TREEWALKER = "NetSoup::XML::DOM2::Traversal::TreeWalker";
1;


sub initialise {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Time => time
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Year        = shift;                                                 # Get object
  my %args        = @_;                                                    # Get arguments
  $Year->{Time}   = $args{Time} || time;
  $Year->{Starts} = $args{Starts};
  $Year->{Months} = [];
  for( my $i = 1 ; $i <= 12 ; $i++ ) {
    $Year->{Months}->[$i] = NetSoup::Oyster::Component::Calendar::Month->new( Time => $Year->{Starts}->[$i] );
  }
  return( $Year );
}


sub getMonth {
  # This method returns a reference to a Month object in the Year object.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Index => 1 .. 12
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Year  = shift;                    # Get object
  my %args  = @_;                       # Get arguments
  my $Index = $args{Index};
  return( $Year->{Months}->[$Index] );
}


sub setMonth {
  # This method replaces a Month object.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Index => 1 .. 12
  #              Month => $Month
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Year  = shift;                    # Get object
  my %args  = @_;                       # Get arguments
  my $Index = $args{Index};
  my $Month = $args{Month};
  $Year->{Months}->[$Index] = $Month;
  return( $Year->{Months}->[$Index] );
}


sub XML {
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
  my $Year  = shift;                                                 # Get object
  my %args   = @_;                                                    # Get arguments
  my $Matrix = $Year->{Matrix};
  my $XML    = "";
  $XML .= qq(<table border="0" cellspacing="0" cellpadding="4"><tr>);
  for( my $i = 1 ; $i <= 3 ; $i++ ) {
    $XML .= qq(<td valign="top">);
    $XML .= $Year->{Months}->[$i]->XML();
    $XML .= qq(</td>);
  }
  $XML .= qq(</tr><tr>);
  for( my $i = 4 ; $i <= 6 ; $i++ ) {
    $XML .= qq(<td valign="top">);
    $XML .= $Year->{Months}->[$i]->XML();
    $XML .= qq(</td>);
  }
  $XML .= qq(</tr><tr>);
  for( my $i = 7 ; $i <= 9 ; $i++ ) {
    $XML .= qq(<td valign="top">);
    $XML .= $Year->{Months}->[$i]->XML();
    $XML .= qq(</td>);
  }
  $XML .= qq(</tr><tr>);
  for( my $i = 10 ; $i <= 12 ; $i++ ) {
    $XML .= qq(<td valign="top">);
    $XML .= $Year->{Months}->[$i]->XML();
    $XML .= qq(</td>);
  }
  $XML .= qq(</tr></table>);
  return( $XML );
}
