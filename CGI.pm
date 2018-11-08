#!/usr/local/bin/perl
#
#   NetSoup::CGI.pm v00.00.01b 12042000
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
#   Description: This Perl Class Library is an object oriented library of routines
#                for decoding and processing information returned from an Html
#                form on the World Wide Web.
#                The methods provided in this class are intended to be reusable
#                and may be included in any Perl script that requires CGI facilities.
#
#
#   Methods:
#       new          -  This method is the object constructor for this class
#       fields       -  This method returns the field list as an array
#       field        -  This method will return the value of a given field
#       insert       -  This method will insert a new field into the object
#       filename     -  This method returns the filename associated with a given field
#       _raw         -  This PRIVATE method reads data from either a GET or POST request
#       _parse       -  This PRIVATE method decodes data generated by _raw
#       _fieldNames  -  This PRIVATE method builds the field list for the new object


package NetSoup::CGI;
use strict;
use NetSoup::Core;
use NetSoup::CGI::Debug;
use NetSoup::URL::Escape;
use NetSoup::Text::CodePage::html2url;
use NetSoup::Text::CodePage::html2mac;
use NetSoup::Text::CodePage::html2win;
@NetSoup::CGI::ISA = qw( NetSoup::Core );
use constant URLESCAPE => NetSoup::URL::Escape->new();        # URL Encoding object
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    _env
  #    _parse
  # Parameters Required:
  #    class
  # Result Returned:
  #    object
  # Example:
  #    my $CGI = NetSoup::CGI->new();
  my $CGI              = shift;
  my %args             = @_;
  $CGI->{MimeBoundary} = "";
  $CGI->{Files}        = {};                                     # Assign anonymous hash to hold filenames
  $CGI->{Fields}       = [];                                     # Assign anonymous array
  $CGI->{Formats}      = { Raw   => $CGI->_raw(),                # Initialise data format containers
                           Html  => {},
                           Ascii => {},
                           Mac   => {},
                           Win   => {} };
  if( exists $ENV{CONTENT_TYPE} ) {                              # Check for valid CONTENT_TYPE environment variable
    if( $ENV{CONTENT_TYPE} =~ m/multipart.form-data/i ) {        # Configure MIME boundary
      my @pair             = split( /;/, $ENV{CONTENT_TYPE} );   # Split on semi-colon
      my $boundary         = $pair[1];                           # Get boundary part
      $boundary            =~ s/\s//g;                           # Strip white space
      $boundary            =~ s/^boundary=//i;                   # Strip boundary= string
      $boundary            =~ s/(\r?\n?)?$/\r\n/;                # Add trailing return new line
      $CGI->{MimeBoundary} = "--" . $boundary;                   # Set MIME boundary
    }
  }
  if( $CGI->{MimeBoundary} ) {                                   # Decode into raw Ascii only
    $CGI->_parse( Format => "ascii" );                           # Ascii Data Format Fields
  } else {                                                       # Decode into all formats
    $CGI->_parse( Format => "ascii" );                           # Ascii Data Format Fields
    $CGI->_parse( Format => "html" );                            # Html Data Format Fields
    $CGI->_parse( Format => "mac" );                             # Mac Data Format Fields
    $CGI->_parse( Format => "win" );                             # Win32 Data Format Fields
  }
  foreach my $field ( sort keys %{$CGI->{Formats}->{Ascii}} ) {  # Iterate over field names
    push( @{$CGI->{Fields}}, $field );                           # Add field name to array
  }
}


sub _raw {
  # This PRIVATE method reads the input from either a GET
  # or POST Html form and return it as a raw scalar.
  # Calls:
  #    none
  # Parameters Required:
  #    class
  # Result Returned:
  #    scalar | undef
  # Example:
  #    my $string = _raw();
  my $CGI   = shift;
  my %args  = @_;                                                 # Get arguments
  my $query = "";                                                 # Scalar holds query data
  if( exists $ENV{REQUEST_METHOD} ) {                             # Check for valid REQUEST_METHOD environment variable
  METHOD: for( $ENV{REQUEST_METHOD} ) {
      m/GET/i && do {                                             # Check for GET request method
        $query = scalar( $ENV{QUERY_STRING_UNESCAPED} ||          # Grab query string
                         $ENV{QUERY_STRING} ||
                         $ENV{REDIRECT_QUERY_STRING} ||
                         $ENV{REDIRECT_REDIRECT_QUERY_STRING} ||
                         "" );                                    # Some kind of cock up has occurred
        $query =~ s/\\\&/\&/gs;
        last METHOD;
      };
      m/POST/i && do {                                            # Check for POST request method
        return $query if( int $ENV{CONTENT_LENGTH} == 0 );        # Check content length size not zero
        read( STDIN, $query, int $ENV{CONTENT_LENGTH} );          # Read input from STDIN
        last METHOD;
      };
    }
  }
  return( $query );
}


sub _parse {
  # This PRIVATE method decodes the raw data generated by the _raw method.
  # Calls:
  #    _decodeChars
  # Parameters Required:
  #    object
  #    data format    Html | Ascii | Mac | Win
  # Result Returned:
  #    boolean
  # Example:
  #    _parse( $dataFormat );
  my $CGI    = shift;
  my %args   = @_;                                                             # Get arguments
  my $format = $args{Format};                                                  # Get data format
  my $query  = $CGI->{Formats}->{Raw};                                         # Get query string from object
  if( ( exists $ENV{CONTENT_TYPE} ) &&
      ( $ENV{CONTENT_TYPE} =~ m/multipart.form-data/i ) ) {                    # Decode multipart MIME encoded data stream
    my $term = $CGI->{MimeBoundary};                                           # Grab boundary
    $term    =~ s/\r\n$//;                                                     # Trim trailing return new line
    return(0) unless( $query =~ s/($term--\r?\n)$//s );                        # Return on incomplete transmission
    foreach my $segmentData ( split( /\Q$CGI->{MimeBoundary}\E/, $query ) ) {  # Iterate over data segments
      if( $segmentData ) {
        $segmentData      =~ s/(^.+\r?\n\r?\n)//s;                             # Strip segment header
        my @segmentHeader = split( /;/, $1 );                                  # Obtain segment header information
        $segmentData      =~ s/\r?\n?$//s;                                     # Strip trailing return new line
        my $segmentName   = $segmentHeader[1];                                 # Get segment name
        $segmentName      =~ m/\"(.+)\"/i;                                     # Strip out label data
        $segmentName      = $1;                                                # Grab parsed name data
        if( $segmentHeader[2] ) {                                              # Configure filename
          my ( $filename )     = ( $segmentHeader[2] =~ m/\"(.+)\"/ );         # Extract filename
          $filename            = URLESCAPE->unescape( Text => $filename );     # Decode hex encoding
          $filename            =~ s/\s/_/gi;                                   # Convert white space to underscores
          $CGI->{Files}->{$segmentName} = $filename;                           # Insert filename into object data member
        }
        $CGI->{Formats}->{$format}->{$segmentName} = $segmentData;             # Insert segment data into object data member
      }
    }
    return(1);
  } else {                                                                     # Decode URL encoded data stream
    return(0) if( ! $query );                                                  # Return on empty query string
    my @query = ();                                                            # Create empty array to hold query string
    if( $query =~ m/&/ ) {                                                     # Break $query into component field/value pairs
      @query = split( /&/, $query );
    } else {
      @query = ( $query );
    }
    foreach ( @query ) {
      my ( $name, $value )       = split( /=/, $_ );                           # Crack field/value pairs
      $value                    .= ", ";
      $value                     =~ s/\+/ /gs;                                 # Convert '+' symbols into real spaces
      $value                     =~ s/, $//;                                   # Trim trailing delimiter
      $CGI->{Formats}->{$format}->{$name} = $value;                            # Add to hash
    SWITCH: for( "$format" ) {                                                 # Determine required format
        my $html2url = NetSoup::Text::CodePage::html2url->new();
        my $raw      = $CGI->{Formats}->{$format}->{$name};
        m/ascii/i && do {
          $raw = URLESCAPE->unescape( URL => $raw );
          $CGI->{Formats}->{Ascii}->{$name} = $raw;
          last SWITCH;
        };
        ( m/html/i || m/^$/ ) && do {
          $html2url->url2html( Data => \$raw );
          $CGI->{Formats}->{Html}->{$name} = $raw;
          last SWITCH;
        };
        m/mac/i && do {
          my $html2mac = NetSoup::Text::CodePage::html2mac->new();
          my $copy     = $CGI->{Formats}->{Html}->{$name};
          $html2mac->html2mac( Data => \$copy );
          $CGI->{Formats}->{Mac}->{$name} = $copy;
          last SWITCH;
        };
        m/win/i && do {
          my $html2win = NetSoup::Text::CodePage::html2win->new();
          my $copy     = $CGI->{Formats}->{Html}->{$name};
          $html2win->html2win( Data => \$copy );
          $CGI->{Formats}->{Win}->{$name} = $copy;
          last SWITCH;
        };
      }
    }
  }
  return(1);
}


sub fields {
  # This method returns the field list as an array.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    array
  # Example:
  #    @fields = $CGI->fields();
  my $CGI = shift;    # Get CGI object
  return( @{$CGI->{Fields}} );  # Return field names
}


sub field {
  # This method will return the value of a given field.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash {
  #           Name   => $name
  #           Format => Html | Ascii | Mac | Win
  #         }
  # Result Returned:
  #    scalar
  # Example:
  #    my $field = $CGI->field( Name => $name, Format => "ascii" );
  my $CGI    = shift;                                # Get CGI object
  my %args   = @_;                                   # Get arguments
  my $name   = $args{Name};                          # Get request field
  my $format = $args{Format} || "";                  # Get format
  $format    = ucfirst( lc( $format ) );             # Tidy up
  if( exists $CGI->{Formats}->{Ascii}->{$name} ) {
  SWITCH: for( "$format" ) {
      m/ascii/i && return $CGI->{Formats}->{Ascii}->{$name};  #
      m/html/i  && return $CGI->{Formats}->{Html}->{$name};
      m/mac/i   && return $CGI->{Formats}->{Mac}->{$name};
      m/win/i   && return $CGI->{Formats}->{Win}->{$name};
      return $CGI->{Formats}->{Html}->{$name};                # Return default html value
    }
  } else {
    return( undef );
  }
}


sub insert {
  # This method will insert a new field into the object.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash {
  #           Name   => $name
  #           Format => Html | Ascii | Mac | Win
  #         }
  # Result Returned:
  #    boolean
  # Example:
  #    $CGI->field( Name => "function", Value => "html" );
  my $CGI                        = shift;                  # Get CGI object
  my %args                       = @_;                     # Get arguments
  my $value                      = $args{Value} || undef;  # Get value
  $CGI->{Formats}->{Html}->{$args{Name}}  = $value;                 # Set Html field data
  $CGI->{Formats}->{Ascii}->{$args{Name}} = $value;                 # Set Ascii field data
  $CGI->{Formats}->{Mac}->{$args{Name}}   = $value;                 # Set Mac field data
  $CGI->{Formats}->{Win}->{$args{Name}}   = $value;                 # Set Win field data
  push( @{$CGI->{Fields}}, $args{Name} );                            # Insert new field name into object
  return( $CGI );
}


sub filename {
  # This method returns the filename associated with a given field.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    field name    scalar
  # Result Returned:
  #    scalar
  # Example:
  #    my $filename = $CGI->filename( $fieldName );
  my $CGI      = shift;         # Get CGI object
  my $filename = shift;
  return( $CGI->{Files}->{$filename} );  # Return filename
}
