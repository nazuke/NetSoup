#!/usr/local/bin/perl
#
#   NetSoup::HTML::Parser::Neanderthal::Document.pm v00.00.01g 12042000
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
#   Description: This Perl 5.0 class provides a shortcut to parsing
#                reasonably error free HTML files using the NetSoup
#                XML Parser.
#
#   Methods:
#       parse  -  This method parses a chunk of HTML text into a DOM2 parse tree


package NetSoup::HTML::Parser::Neanderthal::Document;
use strict;
use NetSoup::Core;
@NetSoup::HTML::Parser::Neanderthal::Document::ISA = qw( NetSoup::Core );
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    Document
  #    hash {
  #           HTML   => \$HTML
  #           Links  => \@Links
  #           Images => \@Images
  #         }
  # Result Returned:
  #    $Document
  # Example:
  #    method call
  my $Document        = shift;
  my %args            = @_;
  $Document->{HTML}   = $args{HTML};
  $Document->{Links}  = $args{Links};
  $Document->{Images} = $args{Images};
  return( $Document );
}


sub links {
  # This method returns a list of image URLs found in the Document.
  # Calls:
  #    none
  # Parameters Required:
  #    Document
  # Result Returned:
  #    @array
  # Example:
  #    method call
  my $Document = shift;
  my %args     = @_;
  #print( join( "\n", @{$Document->{Links}} ) );
  return( @{$Document->{Links}} );
}


sub images {
  # This method returns a list of URLs found in the Document.
  # Calls:
  #    none
  # Parameters Required:
  #    Document
  # Result Returned:
  #    @array
  # Example:
  #    method call
  my $Document = shift;
  my %args     = @_;
  return( @{$Document->{Images}} );
}
