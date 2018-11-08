#!/usr/local/bin/perl
#
#   NetSoup::Text::HTML::Protect.pm v00.00.01a 12042000
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
#   Description: This Perl 5.0 class provides object methods for protecting
#                the tags within Html data.
#
#
#   Methods:
#       protect  -  This method protects Html tags
#       restore  -  This method restores the Html tags


package NetSoup::Text::HTML::Protect;
use strict;
use NetSoup::Core;
use NetSoup::Text::Tokenise;
@NetSoup::Text::HTML::Protect::ISA = qw( NetSoup::Core );
1;


sub protect {
  # This method protects Html tags.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Data  => \$data
  #              [ Pad => 1 ]
  #            }
  # Result Returned:
  #    none
  # Example:
  #    $object->protect( Data => \$data );
  my $object       = shift;                                 # Get object
  my %args         = @_;                                    # Get arguments
  my $data         = $args{Data};                           # Get reference to data
  my $tokenise     = NetSoup::Text::Tokenise->new();        # Get new tokenise object
  $object->{Pairs} = {};                                    # Hash will contain protected token/tag pairs
  foreach my $pattern ( "(<%.+?%>)", "(<[^>]+?>)" ) {
    while ( $$data =~ m/$pattern/gs ) {                     # Protect all Html tags
      my $tag                    = $1;                      # Store tag
      my $token                  = $tokenise->nextToken();  # Get next token
      $object->{Pairs}->{$token} = $tag;                    # Store token/tag pair
      if( exists $args{Pad} ) {                             # Pad with newlines
        $$data =~ s/\Q$tag\E/\x0A$token\x0A/;               # Replace tag with token
      } else {
        $$data =~ s/\Q$tag\E/$token/;                       # Replace tag with token
      }
    }
  }
  return(1);
}


sub restore {
  # This method restores the Html tags.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Data  => \$data
  #              [ Pad => 1 ]
  #            }
  # Result Returned:
  #    none
  # Example:
  #    $object->restore( Data => \$data );
  my $object = shift;                                                     # Get object
  my %args   = @_;                                                        # Get arguments
  my $data   = $args{Data};                                               # Get reference to data
  foreach my $token ( reverse( sort( keys( %{$object->{Pairs}} ) ) ) ) {  # Restore all Html tags
    if( exists $args{Pad} ) {                                             # Padded with newlines
      $$data =~ s/\x0A\Q$token\E\x0A/$object->{Pairs}->{$token}/gs;       # Replace token with tag
    } else {
      $$data =~ s/\Q$token\E/$object->{Pairs}->{$token}/gs;               # Replace token with tag
    }
  }
  return(1);
}
