#!/usr/local/bin/perl
#
#   NetSoup::Protocol::HTTP::Cookies.pm v00.00.01b 12042000
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
#       setCookie  -  This method builds and returns an HTTP cookie header
#       getCookie  -  This method gets a cookie value from the environment


package NetSoup::Protocol::HTTP::Cookies;
use strict;
use NetSoup::Encoding::Hex;
@NetSoup::Protocol::HTTP::Cookies::ISA = qw( NetSoup::Core );
1;


sub initialise {
  # This method is the object initialiser.
  # Calls:
  #    none
  # Parameters Required:
  #    Cookies
  # Result Returned:
  #    boolean
  # Example:
  #    $Cookies->initialise();
  my $Cookies          = shift;                          # Get Cookies object
  my %args             = @_;                             # Get remaining arguments
  $Cookies->{Encoding} = NetSoup::Encoding::Hex->new();
  return( $Cookies );
}


sub setCookie {
  # This method builds and returns an HTTP cookie header.
  # The expiry date is expected to be in number of seconds from now.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Key    => $key
  #              Value  => $value
  #              Expire => $expire in seconds
  #              Path   => $path
  #              Domain => $domain
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    $Cookies->setCookie( "key", "value", $expires );
  my $Cookies = shift;                                                                       # Get Cookies object
  my %args    = @_;                                                                          # Get remaining arguments
  my $key     = $args{Key};                                                                  # Get key of cookie to set
  my $value   = $args{Value};                                                                # Get cookie value
  my $expires = $args{Expire};                                                               # Get expiry date in seconds
  my $path    = $args{Path} || "/";
  my $domain  = $args{Domain} || "";
  my @days    = ( "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun" );
  my @months  = ( "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" );
  my ( $sec, $min, $hour, $mday, $mon,
       $year, $wday,$yday, $isdst ) = gmtime( time + int( $expires ) );                      # Get time and add offset in seconds
  $year    = 1900 + $year;                                                                   # Make four digit year
  $expires = "$days[$wday], $mday $months[$mon] $year $hour:$min:$sec GMT";                  # Configure GMT date
  return( "Set-Cookie: " . join( "; ",                                                       # Return configure cookie HTTP header
                                 "$key=" . $Cookies->{Encoding}->bin2hex( Data => $value ),
                                 "path=$path",
                                 "expires=$expires",
                                 "domain=$domain" ) );
}


sub getCookie {
  # This method gets a cookie value from the environment.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Key => $key
  #            }
  # Result Returned:
  #    scalar
  # Example:
  #    my $cookie = $Cookies->getCookie( Key => $key );
  my $Cookies = shift;                                         # Get Cookies object
  my %args    = @_;                                            # Get remaining arguments
  my $key     = $args{Key};                                    # Get key of cookie to find
  my $cookie  = "";                                            # Stores cookie value
  if( exists $ENV{HTTP_COOKIE} ) {                             # Check for key existence
    my $value = $ENV{HTTP_COOKIE};                             # Store temporary copy of cookies
    $value    =~ s/\s//g;                                      # Compact white space
    my @array = split( /; ?/, $value );                        # Split into separate cookies
    my %pairs = ();
    foreach ( @array ) {
      my @tmp         = split( "=" );                          # Split key/value pairs
      $pairs{$tmp[0]} = $tmp[1];                               # Assign to hash key
    }
    if( $pairs{$key} ) {                                       # Attempt to locate required key/value
      $cookie = $pairs{$key};                                  # Set value from cookie
    } else {                                                   # Else clear value
      return( undef );                                         # Set null value
    }
  } else {
    return( undef );                                           # Set null value
  }
  return( $Cookies->{Encoding}->hex2bin( Data => $cookie ) );  # Return decoded cookie
}
