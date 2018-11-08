#!/usr/local/bin/perl
#
#   NetSoup::Oyster::Document.pm v00.00.01a 12042000
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


package NetSoup::Oyster::Document;
use strict;
use NetSoup::Core;
use NetSoup::Files::Load;
use NetSoup::Protocol::HTTP;
@NetSoup::Oyster::Document::ISA = qw( NetSoup::Core );
1;


sub initialise {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    $Document
  #    hash    {
  #              Key => Value
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Document          = shift;              # Get Document object
  my %args              = @_;                 # Get arguments
  $Document->{Target}   = undef;              # Reference to target scalar
  $Document->{Type}     = "text/html";        # Set default content-type
  $Document->{Location} = "";                 # Clear location URL
  $Document->{Registry} = { UseCache => 1,    # Document cache flag
                            Sources  => [],
                            SSI      => 0 };  # List of contributing source files
  return(1);
}


sub target {
  # This method attaches the Document to a scalar reference.
  # Calls:
  #    none
  # Parameters Required:
  #    $Document
  #    hash    {
  #              Target => \$target
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Document        = shift;          # Get Document object
  my %args            = @_;             # Get arguments
  $Document->{Target} = $args{Target};  # Set target scalar
  return(1);
}


sub out {
  # This method appends a string to the Target.
  # Calls:
  #    none
  # Parameters Required:
  #    $Document
  #    $string
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Document = shift;                # Get Document object
  my $Target   = $Document->{Target};  #
  my $text     = shift;
  $$Target    .= $text;
  return(1);
}


sub result {
  # This method returns the completed document text.
  # Calls:
  #    none
  # Parameters Required:
  #    $Document
  #    hash    {
  #              Result => $Result
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Document = shift;                   # Get Document object
  my %args     = @_;                      # Get arguments
  my $Result   = $args{Result} || undef;  #
  my $Target   = $Document->{Target};     #
  if( defined $Result ) {
    $Document->{Target} = \$Result;
  }
  return( $$Target );
}


sub type {
  # This method sets the content-type used by the rendering host.
  # Calls:
  #    none
  # Parameters Required:
  #    $Document
  #    hash    {
  #              [ Type => $Type ]
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Document      = shift;                      # Get Document object
  my %args          = @_;                         #
  my $Type          = $args{Type} || undef;       #
  $Document->{Type} = $Type if( defined $Type );  #
  return( $Document->{Type} );
}


sub location {
  # This method redirects the document to a new URL.
  # Calls:
  #    none
  # Parameters Required:
  #    $Document
  #    hash    {
  #              URL => $URL
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Document          = shift;                    # Get Document object
  my %args              = @_;                       #
  my $URL               = $args{URL} || undef;      #
  $Document->{Location} = $URL if( defined $URL );  #
  return( $Document->{Location} );
}


sub include {
  # This method includes the contents of the specified document.
  # Calls:
  #    none
  # Parameters Required:
  #    $Document
  #    hash    {
  #              File => $pathname
  #              URL  => $URL
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Document = shift;                   # Get Document object
  my %args     = @_;                      # Get arguments
  my $File     = $args{File} || undef;
  my $URL      = $args{URL}  || undef;
  if( defined $File ) {
    my $Load = NetSoup::Files::Load->new();
    my $HTML = "";
  SWITCH: for( $File ) {
      m/^\// && do {
        $File = $ENV{DOCUMENT_ROOT} . $File;
        last SWITCH
      };
      m/^[^\/]/ && do {
        my $path = $ENV{PATH_TRANSLATED};
        $path    =~ s:[^\\/]+$::;
        $File    = $path . $File;
        last SWITCH
      };
    }
    if( -e $File ) {
      if( $Load->load( Pathname => $File, Data => \$HTML ) ) {
        $Document->out( $HTML );
      } else {
        $Document->out( qq(<p style="color:red;">ERROR: The file "$File" could not be included</p>) );
      }
    } else {
      $Document->out( qq(<p style="color:red;">ERROR: The file "$File" does not exist</p>) );
    }
  }
  if( defined $URL ) {
    my $HTTP  = NetSoup::Protocol::HTTP->new( HTTPUserAgent => $ENV{HTTP_USER_AGENT} );
    my $HTDOC = $HTTP->get( URL => $URL );
    $Document->out( $HTDOC->body() );
    return(1);
  }
  return( $File );
}


sub cache {
  # This method returns the caching flag.
  # Calls:
  #    none
  # Parameters Required:
  #    Document
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Document = shift;                         # Get object
  my %args     = @_;                            # Get arguments
  return( $Document->{Registry}->{UseCache} );  #
}


sub nocache {
  # This method switches off caching for this execution run.
  # Calls:
  #    none
  # Parameters Required:
  #    Document
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Document = shift;                         # Get object
  my %args     = @_;                            # Get arguments
  $Document->{Registry}->{UseCache} = 0;        # Deactivate caching
  return( $Document->{Registry}->{UseCache} );  #
}


sub registerSource {
  # This method registers a source file with the document.
  # The executor will check to see of the source file
  # is newer than the cached file, the cached file will
  # be served if no regeneration is required.
  # Calls:
  #    none
  # Parameters Required:
  #    $Document
  #    hash    {
  #              Source => $pathname
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Document = shift;                                  # Get Document object
  my %args     = @_;                                     # Get arguments
  my $Source   = $args{Source};
  push( @{$Document->{Registry}->{Sources}}, $Source );  # Add file to registered sources
  return(1);
}


sub _sources {
  # This method returns an array of the registered source documents.
  # Calls:
  #    none
  # Parameters Required:
  #    $Document
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Document = shift;                           # Get Document object
  my %args     = @_;                              # Get arguments
  return( @{$Document->{Registry}->{Sources}} );  # Return list of registered source files
}


sub ssi {
  # This method enables server-side parsing of the resultant
  # output, using Apache server-side-include syntax.
  # Calls:
  #    none
  # Parameters Required:
  #    $Document
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Document = shift;              # Get Document object
  my %args     = @_;                 # Get arguments
  $Document->{Registry}->{SSI} = 1;  # Raise SSI flag
  return(1);
}


sub _ssi {
  my $Document = shift;                    # Get Document object
  my %args     = @_;                       # Get arguments
  return( $Document->{Registry}->{SSI} );  # Return SSI flag
}
