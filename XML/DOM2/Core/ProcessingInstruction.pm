#!/usr/local/bin/perl
#
#   NetSoup::XML::DOM2::Core::ProcessingInstruction.pm v00.00.01a 12042000
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


package NetSoup::XML::DOM2::Core::ProcessingInstruction;
use strict;
use NetSoup::XML::DOM2::Core::Node;
@NetSoup::XML::DOM2::Core::ProcessingInstruction::ISA = qw( NetSoup::XML::DOM2::Core::Node );
my $MODULE = "ProcessingInstruction";
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Target => $target
  #              Data   => $data
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    my $ProcessingInstruction = NetSoup::XML::DOM2::Core::ProcessingInstruction->new( Target => $target, Data => $data );
  my $ProcessingInstruction                  = shift;                          # Get element object
  my %args                                   = @_;                             # Get arguments
  $ProcessingInstruction->SUPER::initialise( %args );                          # Perform base class initialisation
  $ProcessingInstruction->{Node}->{NodeType} = "PROCESSING_INSTRUCTION_NODE";  # Set node type
  $ProcessingInstruction->{Node}->{Target}   = $args{Target};                  # Set Processing Instruction target
  $ProcessingInstruction->{Node}->{Data}     = $args{Data};                    # Set Processing Instruction data value
  return( $ProcessingInstruction );                                            # Return ProcessingInstruction object
}


sub target {
  # This method gets/sets the Processing Instruction Target property.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Target => $target
  #            }
  # Result Returned:
  #    $ProcessingInstruction
  # Example:
  #    my $target = $ProcessingInstruction->target( Target => $target );
  my $ProcessingInstruction = shift;                           # Get object
  my %args                  = @_;                              # Get arguments
  if( exists $args{Target} ) {
    $ProcessingInstruction->{Node}->{Target} = $args{Target};  # Set Target
  }
  return( $ProcessingInstruction->{Node}->{Target} );
}


sub data {
  # This method gets/sets the Processing Instruction Data property.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Data => $data
  #            }
  # Result Returned:
  #    $ProcessingInstruction
  # Example:
  #    my $data = $ProcessingInstruction->Data( Data => $data );
  my $ProcessingInstruction = shift;                       # Get object
  my %args                  = @_;                          # Get arguments
  if( exists $args{Data} ) {
    $ProcessingInstruction->{Node}->{Data} = $args{Data};  # Set Target
  }
  return( $ProcessingInstruction->{Node}->{Data} );
}
