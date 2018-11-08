#!/usr/local/bin/perl
#
#   NetSoup::CGI::Form::Validate.pm v00.00.01a 12042000
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


package NetSoup::CGI::Form::Validate;
use strict;
use NetSoup::Core;
use NetSoup::CGI;
use NetSoup::Files::Load;
use NetSoup::XML::Parser;
use NetSoup::XML::DOM2::Traversal::TreeWalker;
@NetSoup::CGI::Form::Validate::ISA = qw( NetSoup::Core );
my $TREEWALKER = "NetSoup::XML::DOM2::Traversal::TreeWalker";
1;


sub validate {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Pathname => $pathname
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Validate = shift;  # Get Validate object
  my %args     = @_;     # Get arguments
  my $Pathname = $args{Pathname};
  my $Load     = NetSoup::Files::Load->new();
  my $CGI      = NetSoup::CGI->new();
  my $Parser   = NetSoup::XML::Parser->new();
  my $XML      = "";
  my $Message  = "";
  $Load->load( Pathname => $Pathname, Data => \$XML );  #
  my $Document = $Parser->parse( XML => \$XML );
  if( defined $Document ) {
    my $TreeWalker = $TREEWALKER->new( Root        => $Document,
                                       CurrentNode => $Document,
                                       Filter      => sub { return(1) } );
    my $Callback = sub {
      my $Node = shift;
    TYPE: for( $Node->nodeName() ) {
        m/^string$/ && do {
          $Message = $CGI->field( Name => $Node->nodeName(), Format => "ascii" );
          my %params = { Mandatory => $Node->getAttribute( Name => "mandatory" ) || "no",
                         MinLength => $Node->getAttribute( Name => "minlength" ) || undef,
                         MaxLength => $Node->getAttribute( Name => "maxlength" ) || undef };

          


          last TYPE;
        };
        m/^int$/ && do {
          last TYPE;
        };
        m/^float$/ && do {
          last TYPE;
        };
        m/^list$/ && do {
          last TYPE;
        };
        m/^multiple$/ && do {
          last TYPE;
        };
      }
      return(1);
    };
    $TreeWalker->walkTree( Node     => $Document,
                           Callback => $Callback );
  } else {
    $Validate->debug( "Sod it!\n" );
    return( undef ); # Indicates failure
  }
  return( $Message );
}
