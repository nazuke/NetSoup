#!/usr/local/bin/perl
#
#   NetSoup::XML::Parser::Errors.pm v00.00.01a 12042000
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
#   Description: This Perl 5.0 class is part of the XML DOM2 system.
#                This class provides methods for formatted error reporting.
#
#
#   Methods:
#       _sample  -  This private method constructs a line sample string for the error method
#       _error   -  This private method generates a message on STDERR if debugging is enabled
#       error    -  This method returns a hash of the error last fatal error to the host application


package NetSoup::XML::Parser::Errors;
use strict;
use NetSoup::Core;
@NetSoup::XML::Parser::Errors::ISA = qw( NetSoup::Core );
my $MODULE = "Errors";
1;


sub clearErr {
  # This method clears the stored error messages.
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
  my $Errors                    = shift;  # Get object
  my %args                      = @_;     # Get arguments
  $Errors->{Errors}->{Count}    = 0;
  $Errors->{Errors}->{Nodes}    = [];
  $Errors->{Errors}->{Messages} = [];
  $Errors->{Errors}->{Types}    = [];
  $Errors->{Errors}->{Samples}  = [];
  return(1);
}


sub _error {
  # This private method generates an error message.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Errors => \%errors
  #              Module => $module
  #              Symbol => $symbol
  #              Line   => $line
  #              Code   => $code
  #              String => $string
  #              Sample => $sample
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Errors   = shift;                                    # Get object
  my %args     = @_;                                       # Get arguments
  $args{Level} = "Error";                                  # Set message level
  my @messages = $Errors->_format( %args );                # Format message
  push( @{$Errors->{Errors}->{Messages}}, $messages[0] );  #
  push( @{$Errors->{Errors}->{Types}},    $messages[1] );
  push( @{$Errors->{Errors}->{Samples}},  $messages[2] );
  $Errors->{Errors}->{Count}++;                            # Increment error count
  return(1);
}


sub _warning {
  # This private method generates a warning message.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Errors => \%errors
  #              Module => $module
  #              Symbol => $symbol
  #              Line   => $line
  #              Code   => $code
  #              String => $string
  #              Sample => $sample
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Errors   = shift;                      # Get object
  
  return(1);                                 # DEBUG
  
  my %args     = @_;                         # Get arguments
  $args{Level} = "Warning";                  # Set message level
  my @messages = $Errors->_format( %args );  # Format message
  print( STDERR $messages[0] );
  print( STDERR $messages[2] . "\n" );
  return(1);
}


sub _format {
  # This private method generates formats a message.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Errors => \%errors
  #              Module => $module
  #              Level  => "Error" | "Warning"
  #              Symbol => $symbol
  #              Line   => $line
  #              Code   => $code
  #              String => $string
  #              Sample => $sample
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Errors  = shift;                                                                # Get object
  my %args    = @_;                                                                   # Get arguments
  my $errors  = $args{Errors};                                                        # Get hash of error codes/messages
  my $module  = $args{Module}  || "";                                                 # Get module name
  $module    .= " " if( $module );                                                    # Add space to module name
  my $state   = $args{State}   || undef;                                              # Get current parser state
  my $symbol  = $args{Symbol}  || "";                                                 # Get current symbol
  my $line    = $args{Line}    || 0;                                                  # Get line number
  my $code    = $args{Code}    || "";                                                 # Get error code
  my $string  = $args{String}  || "";                                                 # Get error code
  my $context = $args{Context} || "";                                                 # Get context
  my $sample  = $args{Sample}  || "";                                                 # Get markup sample
  $sample     =~ s/^\s*(.+)\s*$/$1/;                                                  # Strip white space
  my $error   = $errors->{$code};                                                     # Get error string
  $error      =~ s/__/\"$string\"/gs;                                                 # Insert string into error message
  $error      =~ s/!!/\"$context\"/gs;                                                # Insert context into error message
  my $prolog  = $module . $args{Level};
  my $message = "\t$prolog";
  $message   .= " line $line" if( $line );
  $message   .= ": $error\n";
  $message   .= ( "\t" . ( " " x length( $prolog ) ) . " $symbol\n" ) if( $symbol );  # Output current symbol
  $message   .= ( "\t" . ( " " x length( $prolog ) ) . " $sample\n" ) if( $sample );  # Output markup sample
  return( $message, "$args{Module}:$code", $sample );
}


sub _sample {
  # This private method constructs a line sample string for the error method.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Array  => \@array
  #              Cursor => $i
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $Errors->_sample( Array => \@array, Cursor => 10 );
  my $Errors = shift;                             # Get object
  my %args   = @_;                                # Get arguments
  my $array  = $args{Array};                      # Get reference to array
  my $i      = $args{Cursor} - 1;                 # Calculate starting left position
  my $left   = "";
  my $right  = "";
 LEFT: while( $i >= 0 ) {                         # Work backwards until a newline encountered
    $left = $$array[$i] . $left;
    $i--;
    last LEFT if( $$array[$i] =~ m/[\r\n]/s );    # Break loop on start of current line
  }
  $i = $args{Cursor} + 1;                         # Calculate starting right position
 RIGHT: while( $i <= @$array - 1 ) {              # Work forwards until a newline encountered
    last RIGHT if( $$array[$i] =~ m/[\r\n]/s );   # Break loop on start of current line
    $right .= $$array[$i];
    $i++;
  }
  return( "$left$$array[$args{Cursor}]$right" );  # Return line sample
}


sub count {
  # This method returns the count value.
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
  my $Errors = shift;                    # Get object
  my %args   = @_;                       # Get arguments
  return( $Errors->{Errors}->{Count} );  # Return count value
}


sub errors {
  # This method returns an array of the error messages.
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
  my $Errors = shift;                          # Get object
  my %args   = @_;                             # Get arguments
  return( @{$Errors->{Errors}->{Messages}} );  # Return errors array
}


sub types {
  # This method returns an array of the error messages.
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
  my $Errors = shift;                       # Get object
  my %args   = @_;                          # Get arguments
  return( @{$Errors->{Errors}->{Types}} );  # Return errors array
}


sub samples {
  # This method returns an array of the samples.
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
  my $Errors = shift;                         # Get object
  my %args   = @_;                            # Get arguments
  return( @{$Errors->{Errors}->{Samples}} );  # Return samples array
}
