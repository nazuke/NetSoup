#!/usr/local/bin/perl
#
#   NetSoup::Protocol::HTTP.pm v00.00.01a 12042000
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


package NetSoup::Protocol::HTTP;
use strict;
use NetSoup::Core;
use NetSoup::Protocol;
use NetSoup::Protocol::HTTP::Document;
use NetSoup::Protocol::HTTP::Cookies;
use NetSoup::URL::Parse;
use NetSoup::URL::Escape;
$NetSoup::Protocol::HTTP::BASE64 = 0;
if( eval "use MIME::Base64;" ) {
  $NetSoup::Protocol::HTTP::BASE64 = 1;
}
use NetSoup::Encoding::Base64;
@NetSoup::Protocol::HTTP::ISA = qw( NetSoup::Protocol::HTTP::Cookies );
my $PROTOCOL = "NetSoup::Protocol";
my $DOCUMENT = "NetSoup::Protocol::HTTP::Document";
1;


sub initialise {
  # This method is the object initialiser for this class.
  # Calls:
  #    none
  # Parameters Required:
  #    HTTP
  #    hash    {
  #              Debug => 0 | 1
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $HTTP                = shift;                       # Get HTTP object
  my %args                = @_;                          # Get arguments
  $HTTP->{Debug}          = $args{Debug}          || 0;  #
  $HTTP->{Error}          = 0;                           # Error flag
  $HTTP->{Status}         = "";                          # Reserved for status messages
  $HTTP->{UserAgent}      = $args{HTTPUserAgent}  || "Mozilla/4.75 [en] (X11; U; Linux 2.2.16-22 i686)";
  $HTTP->{AcceptLanguage} = $args{AcceptLanguage} || $ENV{HTTP_ACCEPT_LANGUAGE} || "en";
  $HTTP->SUPER::initialise();
  return( $HTTP );
}


sub get {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    HTTP
  #    hash    {
  #              URL      => $URL
  #              Username => $Username || ""
  #              Password => $Password || ""
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $HTTP     = shift;
  my %args     = @_;
  my $URL      = $args{URL};
  my $Username = $args{Username} || "";
  my $Password = $args{Password} || "";
  my %Headers  = ();
  if( ( length( $Username ) > 0 ) && ( length( $Password ) > 0 ) ) {
    if( $NetSoup::Protocol::HTTP::BASE64 ) {
      $Headers{Authorization} = "BASIC " . encode_base64( "$Username:$Password" );
    } else {
      my $Base64 = NetSoup::Encoding::Base64->new();
      my $string = "$Username:$Password";
      $Headers{Authorization} = "BASIC " . $Base64->bin2base64( Data => $string );
    }
  }
  my $URLParse = NetSoup::URL::Parse->new();
  if( $URLParse->protocol( $URL ) ne "http" ) {
    $HTTP->{Status} = "Unsupported Protocol";
    return( undef );
  }
  if( ! $URLParse->hostname( $URL ) ) {
    $HTTP->{Status} = "Invalid URL";
    return( undef );
  }
  my $Protocol = $PROTOCOL->new( Address => $URLParse->hostname( $URL ),
                                 Port    => $URLParse->port( $URL ) );
  if( ! $Protocol->client() ) {
    $HTTP->{Status} = "Unknown Host";
    $Protocol->disconnect();
    return( undef );
  }
  $Protocol = $PROTOCOL->new( Address => $URLParse->hostname( $URL ),
                              Port    => $URLParse->port( $URL ) );
  $Protocol->client();
  my $Request = $HTTP->_request( Method   => "GET",
                                 Hostname => $URLParse->hostname( $URL ),
                                 Port     => $URLParse->port( $URL ),
                                 Pathname => $URLParse->pathname( $URL ),
                                 Filename => $URLParse->filename( $URL ),
                                 Headers  => \%Headers );
  if( $Protocol->put( Data => \$Request ) ) {
    my $Response = "";
    $Protocol->get( Data => \$Response );
    my $Document = $DOCUMENT->new( Data => $Response );
    $Protocol->disconnect();
    return( $Document );
  }
  $Protocol->disconnect();
  return( undef );
}


sub post {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    HTTP
  #    hash    {
  #              Key => Value
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $HTTP     = shift;
  my %args     = @_;
  my $URL      = $args{URL};
  my $Username = $args{Username} || "";
  my $Password = $args{Password} || "";
  my %Headers  = ();
  my $URLParse = NetSoup::URL::Parse->new();
  my $Protocol = $PROTOCOL->new( Address => $URLParse->hostname( $URL ),
                                 Port    => $URLParse->port( $URL ) );
  $Protocol->client();
  if( ( length( $Username ) > 0 ) && ( length( $Password ) > 0 ) ) {
    if( $NetSoup::Protocol::HTTP::BASE64 ) {
      $Headers{Authorization} = "BASIC " . encode_base64( "$Username:$Password" );
    } else {
      my $Base64 = NetSoup::Encoding::Base64->new();
      my $string = "$Username:$Password";
      $Headers{Authorization} = "BASIC " . $Base64->bin2base64( Data => $string );
    }
  }
  $Headers{"Content-Type"}   = $args{ContentType};
  $Headers{"Content-Length"} = length( $args{Content} );
  my $Request                = $HTTP->_request( Method   => "POST",
                                                Hostname => $URLParse->hostname( $URL ),
                                                Port     => $URLParse->port( $URL ),
                                                Pathname => $URLParse->pathname( $URL ),
                                                Filename => $URLParse->filename( $URL ),
                                                Headers  => \%Headers ) . $args{Content};
  if( $Protocol->put( Data   => \$Request,
                      Length => length( $Request ) ) ) {
    my $Document = $DOCUMENT->new();
    my $Response = "";
    $Protocol->get( Data => \$Response );
    $Document->head( Head => \$Response );
    $Document->body( Body => \$Response );
    return( $Document );
  }
  return( undef );
}


sub _request {
  # This method formulates an HTTP request.
  # Calls:
  #    none
  # Parameters Required:
  #    HTTP
  #    hash    {
  #              Method => "GET" | "POST"
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $HTTP     = shift;
  my %args     = @_;
  my $Method   = $args{Method};
  my $Hostname = $args{Hostname};
  my $Port     = $args{Port} || 80;
  my $Pathname = $args{Pathname};
  my $Filename = $args{Filename};
  my $Query    = $args{Query}   || "";
  my $Headers  = $args{Headers} || {};
  my $Header   = "";
  $Query       = "?" . $Query if( length( $Query ) > 0 );
  foreach my $header ( keys %{$Headers} ) {
    $Header .= "$header: $Headers->{$header}\r\n";
  }
  my $Request = join( "",
                      "$Method ",
                      $Pathname,
                      $Filename,
                      $Query,
                      " HTTP/1.0\r\n",
                      "Connection: close\r\n",
                      "Host: $Hostname:$Port\r\n",
                      "User-Agent: $HTTP->{UserAgent}\r\n",
                      "Accept: text/html, image/gif, image/jpeg, image/png\r\n",
                      "Accept-Language: $HTTP->{AcceptLanguage}\r\n",
                      $Header || "\r\n" );
  $Request .= "\r\n" if( $Header =~ m/[^\r][^\n]\r\n$/s );
  return( $Request );
}


sub escape {
  # This method encodes text suitable for inclusion in a URL.
  # Calls:
  #    none
  # Parameters Required:
  #    HTTP
  #    hash    {
  #              URL => $URL
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $HTTP   = shift;
  my %args   = @_;
  my $Escape = NetSoup::URL::Escape->new();
  return( $Escape->escape( URL => $args{URL} ) );
}


sub unescape {
  # This method decodes URL-encoded text.
  # Calls:
  #    none
  # Parameters Required:
  #    HTTP
  #    hash    {
  #              URL => $URL
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $HTTP   = shift;
  my %args   = @_;
  my $Escape = NetSoup::URL::Escape->new();
  return( $Escape->unescape( URL => $args{URL} ) );
}


sub status {
  # This method returns an informational status message.
  # Calls:
  #    none
  # Parameters Required:
  #    HTTP
  # Result Returned:
  #    scalar
  # Example:
  #    method call
  my $HTTP = shift;
  my %args = @_;
  return( $HTTP->{Status} );
}
