#!/usr/local/bin/perl
#
#   NetSoup::XML::TreeClimber.pm v00.00.01a 12042000
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


package NetSoup::XML::TreeClimber;
use strict;
use XML::DOM;
use NetSoup::Core;
@NetSoup::XML::TreeClimber::ISA = qw( NetSoup::Core );
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Root                   => $Node
  #              WhatToShow             => $whatToShow
  #              Filter                 => sub {}
  #              ExpandEntityReferences => 0 | 1
  #              CurrentNode            => $Node
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $TreeClimber = NetSoup::XML::TreeClimber->new();
  my $TreeClimber        = shift;                               # Get TreeClimber object
  my %args               = @_;                                  # Get arguments
  $TreeClimber->{Filter} = $args{Filter} || sub { return(1) };  # Type NodeFilter
  return( $TreeClimber );                                       # Return blessed TreeClimber object
}


sub climb {
  # This method walks a sub-tree from top to bottom,
  # executing a callback for each Node found.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Node     => $Node
  #              Callback => sub {}
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $TreeClimber->climb();
  my $TreeClimber = shift;                                           # Get TreeClimber object
  my %args        = @_;                                              # Get arguments
  my $Node        = $args{Node}     || return( undef );              # Get Node object
  my $callback    = $args{Callback} || sub {};                       # Get callback to execute
  if( ( defined $TreeClimber->{Filter} ) &&                          # If filter supplied...
      ( &{$TreeClimber->{Filter}}( $Node ) ) ) {                     # ...and filter allows this Node
    my $flag = &$callback( $Node );                                  # Execute callback on Node if filter allows
    return( undef ) if( ! defined $flag );                           # Callback may break out of tree walking
  }
  if( $Node->hasChildNodes() ) {
    my $NodeList = $Node->getChildNodes();
  CHILD: for( my $i = 0 ; $i <= $NodeList->getLength() ; $i++ ) {
      my $ChildNode = $NodeList->item( $i ) || last CHILD;           # Get child node
      my $flag      = $TreeClimber->climb( Node     => $ChildNode,
                                           Callback => $callback );
      return( undef ) if( ! defined $flag );
    }
   }
  return(1);
}


__END__


sub harness {
  my $data        = shift;
  my $Parser   = XML::DOM::Parser->new();
  my $Document    = $Parser->parse( $data );
  my $TreeClimber = NetSoup::XML::TreeClimber->new( Filter => sub {
                                                      my $Node = shift;
                                                    SWITCH: for( $Node->getNodeTypeName() ) {
                                                        m/^ELEMENT_NODE$/ && do {
                                                          return(1);
                                                        };
                                                      }
                                                      return( undef );
                                                    } );
  $TreeClimber->climb( Node     => $Document,
                       Callback => sub {
                         my $Node = shift;
                         print( $Node->getNodeTypeName() . "  " . $Node->getNodeName() . "\n" );
                       } );
  return(1);
}
