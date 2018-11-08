#!/usr/local/bin/perl
#
#   NetSoup::XML::DOM2::Traversal::TreeWalker.pm v00.00.01a 12042000
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


package NetSoup::XML::DOM2::Traversal::TreeWalker;
use strict;
use NetSoup::Core;
@NetSoup::XML::DOM2::Traversal::TreeWalker::ISA = qw( NetSoup::Core );
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
  #    my $TreeWalker = NetSoup::XML::DOM2::Traversal::TreeWalker->new();
  my $TreeWalker                        = shift;                                               # Get TreeWalker object
  my %args                              = @_;                                                  # Get arguments
  $TreeWalker->{Root}                   = $args{Root}                   || undef;              # Type Node
  $TreeWalker->{WhatToShow}             = $args{WhatToShow}             || 0;                  # Type long
  $TreeWalker->{Filter}                 = $args{Filter}                 || sub { return(1) };  # Type NodeFilter
  $TreeWalker->{ExpandEntityReferences} = $args{ExpandEntityReferences} || 0;                  # Type boolean
  $TreeWalker->{CurrentNode}            = $args{CurrentNode}            || undef;              # Type Node
  $TreeWalker->{Stack}                  = [];                                                  # Stack tracks Nodes
  return( $TreeWalker );                                                                       # Return blessed TreeWalker object
}


sub walkTree {
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
  #    $TreeWalker->walkTree();
  my $TreeWalker = shift;                                               # Get TreeWalker object
  my %args       = @_;                                                  # Get arguments
  my $Node       = $args{Node}     || return(1);                        # Get Node object
  my $callback   = $args{Callback} || sub {};                           # Get callback to execute
  if( ( defined $TreeWalker->{Filter} ) &&                              # If filter supplied...
      ( &{$TreeWalker->{Filter}}( $Node ) ) ) {                         # ...and filter allows this Node
    my $flag = &$callback( $Node );                                     # Execute callback on Node if filter allows
    return( undef ) if( ! defined $flag );                              # Callback may break out of tree walking
  }
  if( $Node->hasChildNodes() ) {
     my $NodeList = $Node->childNodes();
  CHILD: for( my $i = 0 ; $i <= $NodeList->nodeListLength() ; $i++ ) {  #
       my $ChildNode = $NodeList->item( Item => $i ) || last CHILD;      # Get child node
      my $flag      = $TreeWalker->walkTree( Node     => $ChildNode,
                                             Callback => $callback );
      return( undef ) if( ! defined $flag );                            # Unwind call stack
    }
   }
  return(1);
}


sub NEWwalkTree {
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
  #    $TreeWalker->walkTree();
  my $TreeWalker             = shift;                                   # Get TreeWalker object
  my %args                   = @_;                                      # Get arguments
  $TreeWalker->{CurrentNode} = $args{Node}     || return(1);            # Get Node object
  my $Callback               = $args{Callback} || sub {};               # Get callback to execute
 WALKER: while( defined $TreeWalker->{CurrentNode} ) {
    if( ( defined $TreeWalker->{Filter} ) &&                            # If filter supplied
        ( &{$TreeWalker->{Filter}}( $TreeWalker->{CurrentNode} ) ) ) {
      &$Callback( $TreeWalker->{CurrentNode} );                         # Execute callback on Node if filter allows
    }
    $TreeWalker->nextNode();
  }
  print( STDERR "\nFinished\n" );
  return(1);
}


sub currentNode {
  # This method returns a Node.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    $Node
  # Example:
  #    my $Node = $TreeWalker->currentNode();
  my $TreeWalker  = shift;                      # Get TreeWalker object
  my %args        = @_;                         # Get arguments
  my $CurrentNode = $args{CurrentNode};
  if( defined $CurrentNode ) {
    $TreeWalker->{CurrentNode} = $CurrentNode;  #
  }
  return( $TreeWalker->{CurrentNode} );         # Return Node object
}


sub parentNode {
  # This method returns a Node.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    $Node
  # Example:
  #    my $Node = $TreeWalker->parentNode();
  my $TreeWalker             = shift;                       # Get TreeWalker object
  my %args                   = @_;                          # Get arguments
  my $Node                   = $TreeWalker->{CurrentNode};  # Get current Node
  $TreeWalker->{CurrentNode} = $Node->parentNode();         # Update current Node
  return( $TreeWalker->{CurrentNode} );                     # Return Node object
}


sub firstChild {
  # This method returns a Node.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    $Node
  # Example:
  #    my $Node = $TreeWalker->firstChild();
  my $TreeWalker = shift;                              # Get TreeWalker object
  my %args       = @_;                                 # Get arguments
  my $Node       = $TreeWalker->{CurrentNode};         # Get current Node
  if( $Node->hasChildNodes() ) {
    $TreeWalker->{CurrentNode} = $Node->firstChild();  # Update current Node
    return( $TreeWalker->{CurrentNode} );              # Return Node object
  }
  return( undef );                                     # Return undef on no child nodes
}


sub lastChild {
  # This method returns a Node.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    $Node
  # Example:
  #    my $Node = $TreeWalker->lastChild();
  my $TreeWalker             = shift;                                    # Get TreeWalker object
  my %args                   = @_;                                       # Get arguments
  $TreeWalker->{CurrentNode} = $TreeWalker->{CurrentNode}->lastChild();  # Update current Node
  return( $TreeWalker->{CurrentNode} );                                  # Return Node object
}


sub previousSibling {
  # This method returns a Node.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    $Node
  # Example:
  #    my $Node = $TreeWalker->previousSibling();
  my $TreeWalker             = shift;                                          # Get TreeWalker object
  my %args                   = @_;                                             # Get arguments
  $TreeWalker->{CurrentNode} = $TreeWalker->{CurrentNode}->previousSibling();  # Update current Node
  return( $TreeWalker->{CurrentNode} );                                        # Return Node object
}


sub nextSibling {
  # This method returns a Node.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    $Node
  # Example:
  #    my $Node = $TreeWalker->nextSibling();
  my $TreeWalker             = shift;                                      # Get TreeWalker object
  my %args                   = @_;                                         # Get arguments
  $TreeWalker->{CurrentNode} = $TreeWalker->{CurrentNode}->nextSibling();  # Update current Node
  return( $TreeWalker->{CurrentNode} );                                    # Return Node object
}


sub previousNode {
  # This method returns a Node.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    $Node
  # Example:
  #    my $Node = $TreeWalker->previousNode();
  my $TreeWalker             = shift;                                          # Get TreeWalker object
  my %args                   = @_;                                             # Get arguments
  $TreeWalker->{CurrentNode} = $TreeWalker->{CurrentNode}->previousSibling();  # Update current Node
  return( $TreeWalker->{CurrentNode} );                                        # Return Node object
}


sub nextNode {
  # This method returns a Node.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    $Node
  # Example:
  #    my $Node = $TreeWalker->nextNode();
  my $TreeWalker = shift;
  my %args       = @_;
  my $Stack      = $TreeWalker->{Stack};


  if( ( ! $TreeWalker->{CurrentNode}->hasChildNodes() ) &&           # Leaf Node
      ( ! $TreeWalker->{CurrentNode}->nextSibling() ) ) {
    $TreeWalker->{CurrentNode} = pop( @{$Stack} );                     # Pop the Node off the stack

    



    return( $TreeWalker->{CurrentNode} );
  }


  if( $TreeWalker->{CurrentNode}->hasChildNodes() ) {
    
    push( @{$Stack}, $TreeWalker->{CurrentNode} );                                # Push the current Node onto the stack
    $TreeWalker->{CurrentNode} = $TreeWalker->{CurrentNode}->firstChild();
    return( $TreeWalker->{CurrentNode} );
  } else {
    
    $TreeWalker->{CurrentNode} = $TreeWalker->{CurrentNode}->nextSibling();
    return( $TreeWalker->{CurrentNode} );
  }



  $TreeWalker->{CurrentNode} = $TreeWalker->{CurrentNode}->nextSibling();


  return( $TreeWalker->{CurrentNode} );
}
