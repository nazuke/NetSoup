#!/usr/local/bin/perl
#
#   NetSoup::Protocol::HTTP::Document.pm v00.00.01a 12042000
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


package NetSoup::Protocol::HTTP::Document;
use strict;
use NetSoup::Core;
@NetSoup::Protocol::HTTP::Document::ISA = qw( NetSoup::Core );
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    Document
  #    hash    {
  #              Debug => 0 | 1
  #              Data  => $Response
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Document         = shift;              # Get Document object
  my %args             = @_;                 # Get arguments
  my $head             = "";
  my $body             = "";
  $Document->{Debug}   = $args{Debug} || 0;  #
  $Document->{Data}    = $args{Data};
  $Document->{Status}  = "";
  $Document->{Headers} = {};
  $Document->{Body}    = "";
  $Document->parse() || return( undef );
  return( $Document );
}


sub parse {
  # This method parses the header fields.
  # Calls:
  #    none
  # Parameters Required:
  #    Document
  #    hash    {
  #
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Document = shift;                            # Get Document object
  my %args     = @_;                               # Get arguments
  my $length   = length( $Document->{Data} ) - 1;  # Number of bytes of raw data
  my %State    = ( InKey => 1,
                   Key   => "",
                   Value => "" );
  my $i        = 0;
 STATUS: for( $i = 0 ; $i <= $length ; $i++ ) {
  SWITCH: for( substr( $Document->{Data}, $i, 1 ) ) {
      m/./ && do {
        $Document->{Status} .= $_;
      };
      m/\n/gs && do {
        $i++;
        last STATUS;
      };
    }
  }
 FIELDS: for( $i = $i ; $i <= length($Document->{Data}) ; $i++ ) {
  SWITCH: for( substr( $Document->{Data}, $i, 1 ) ) {
      m/\n/ && do {
        if( $State{InKey} ) {
          $i++;
          last FIELDS;
        }
      };
      m/:/ && do {
        if( $State{InKey} == 1 ) {
          $State{InKey} = 0;
        } else {
          $State{Value} .= $_;
        }
        last SWITCH;
      };
      m/\n/ && do {
        $State{InKey}                       = 1;
        $State{Value}                       =~ s/^[ \t]*(.+)[ \t]*/$1/;
        $Document->{Headers}->{$State{Key}} = $State{Value} if( $State{Value} );
        $State{Key}                         = "";
        $State{Value}                       = "";
        last SWITCH;
      };
      m/./ && do {
        if( $State{InKey} == 1 ) {
          $State{Key} .= lc($_);
        } else {
          $State{Value} .= $_;
        }
        last SWITCH;
      };
    }
  }
  $Document->{Body} = substr( $Document->{Data}, $i );
  return( length( $Document->{Body} ) );
}


sub status {
  # This method returns the HTTP status line.
  # Calls:
  #    none
  # Parameters Required:
  #    Document
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Document = shift;
  my %args     = @_;              # Get arguments
  return( $Document->{Status} );  #
}


sub method {
  # This method returns the HTTP request method.
  # Calls:
  #    none
  # Parameters Required:
  #    Document
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Document   = shift;
  my %args       = @_;              # Get arguments
  my $status     = $Document->status();
  my ( $method ) = ( $status =~ m/^([^ \t]+)[ \t]/ );
  return( $method );  #
}


sub path {
  # This method returns the HTTP request path.
  # Calls:
  #    none
  # Parameters Required:
  #    Document
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Document = shift;
  my %args     = @_;              # Get arguments
  my $status   = $Document->status();
  my ( $path ) = ( $status =~ m/^[^ \t]+[ \t]+([^ \t]+)/ );
  return( $path );  #
}


sub protocol {
  # This method returns the HTTP request protocol.
  # Calls:
  #    none
  # Parameters Required:
  #    Document
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Document     = shift;
  my %args         = @_;
  my $status       = $Document->status();
  my ( $protocol ) = ( $status =~ m/^[^ \t]+[ \t]+[^ \t]+[ \t]+([^ \t]+)/ );
  return( $protocol );
}


sub fields {
  # This method returns an array of header fields.
  # Calls:
  #    none
  # Parameters Required:
  #    Document
  #    hash    {
  #
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Document = shift;
  return( keys( %{$Document->{Headers}} ) );
}


sub field {
  # This method returns a specific header field.
  # Calls:
  #    none
  # Parameters Required:
  #    Document
  #    hash    {
  #              Name => $name
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Document = shift;
  my %args     = @_;
  my $Name     = lc( $args{Name} );
  my $Field    = "";
 FIELD: foreach my $key ( keys %{$Document->{Headers}} ) {
    if( $key eq $Name ) {
      ( $Field ) = ( $Document->{Headers}->{$key} =~ m/^[ \t]*([^\r\n]+)[\r\n]*$/s );
      last FIELD;
    }
  }
  return( $Field );
}


sub body {
  # This methid returns the message body content.
  # Calls:
  #    none
  # Parameters Required:
  #    Document
  #    hash    {
  #
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Document = shift;         # Get Document object
  my %args     = @_;            # Get arguments
  return( $Document->{Body} );  # Return body content
}
