#!/usr/local/bin/perl
#
#   NetSoup::JavaScript::Parser::Preprocessor.pm v00.00.01a 12042000
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


package NetSoup::JavaScript::Parser::Preprocessor;
use strict;
use NetSoup::Core;
use NetSoup::JavaScript::Parser::Preprocessor::Table;
use NetSoup::JavaScript::Parser::Preprocessor::Symbol;
@NetSoup::JavaScript::Parser::Preprocessor::ISA = qw( NetSoup::Core );
my $TABLE  = "NetSoup::JavaScript::Parser::Preprocessor::Table";
my $SYMBOL = "NetSoup::JavaScript::Parser::Preprocessor::Symbol";
1;


sub initialise {
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
  my $Preprocessor        = shift;  # Get object
  my %args                = @_;     # Get arguments
  $Preprocessor->{Tree}   = {};
  $Preprocessor->{State}  = {};
  $Preprocessor->{Tokens} = [];


  return( $Preprocessor );
}


sub preprocessor {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Script => \$script
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Preprocessor        = shift;                         # Get object
  my %args                = @_;                            # Get arguments
  my $Script              = $args{Script};
  my @chars               = split( //, $$Script );
  my %State               = ( LineNo    => 1,
                              InDblQuot => 0,
                              InSglQuot => 0,
                            );
  $Preprocessor->{Tree}   = {};
  $Preprocessor->{Tokens} = [];


  my $Table               = $TABLE->new();
  my $Symbol              = $SYMBOL->new();


  CHARS: for( my $i = 0 ; $i <= ( @chars - 1 ) ; $i++ ) {  #


    VECT: for( $chars[$i] ) {


      # New Line
      m/\x0A/is && do {
        $State{LineNo}++;
        print( "\nNew Line\n" );
        last VECT;
      };


      # Comment
      m:/:i && do {
        print( $chars[$i] );
        last VECT;
      };


      # Default
      m//i && do {
        print( $chars[$i] );
        last VECT;
      };


    }


  }

  $Table->dumper();


  return( $Preprocessor );
}
