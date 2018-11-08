#!/usr/local/bin/perl
#
#   NetSoup::Apache::Cookies.pm v00.00.01b 12042000
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


package NetSoup::Apache::Cookies;
use strict;
use Digest::MD5;
use NetSoup::Core;
@NetSoup::Apache::Cookies::ISA = qw( NetSoup::Core );
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
  my $Cookies         = shift;           # Get Cookies object
  my %args            = @_;              # Get remaining arguments
  $Cookies->{Request} = $args{Request};  # Apache Request Object
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
  my $Cookies = shift;                                                       # Get Cookies object
  my %args    = @_;                                                          # Get remaining arguments
  my $key     = $args{Key};                                                  # Get key of cookie to set
  my $value   = $args{Value};                                                # Get cookie value
  my $expires = $args{Expires};                                              # Get expiry date in seconds
  my $path    = $args{Path} || "/";
  my $domain  = $args{Domain};
  my @days    = ( "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun" );
  my @months  = ( "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" );
  my ( $sec, $min, $hour, $mday, $mon,
       $year, $wday,$yday, $isdst ) = gmtime( time + int( $expires ) );      # Get time and add offset in seconds
  $year    = 1900 + $year;                                                   # Make four digit year
  $expires = "$days[$wday], $mday-$months[$mon]-$year $hour:$min:$sec GMT";  # Configure GMT date
  chomp( $domain );
  #return( qq($key=$value; EXPIRES=$expires; DOMAIN=$domain; PATH=$path) );
  return( qq($key=$value; EXPIRES=$expires; PATH=$path) );
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
  my $Cookies = shift;                                     # Get Cookies object
  my %args    = @_;                                        # Get remaining arguments
  my $Key     = $args{Key};                                # Get key of cookie to find
  my $cookie  = undef;                                     # Stores cookie value
  if( $Cookies->{Request}->header_in("Cookie") ) {         # Check for key existence
    my $Raw   = $Cookies->{Request}->header_in("Cookie");  # Store temporary copy of cookies
    my @atoms = split( /;[ \t]*/, $Raw );
    my %pairs = ();
    foreach my $atom ( @atoms  ) {
      my ( $name, $value ) = split( m/=/, $atom );         # Split key/value pairs
      $pairs{$name}        = $value;                       # Assign to hash key
    }
    $cookie = $pairs{$Key} if( exists $pairs{$Key} );      # Attempt to locate required key/value
  }
  return( $cookie );
}


sub randCookie {
  # This method generates a randomised cookie value.
  # the Linux device /dev/random is required.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Seed => $seed
  #            }
  # Result Returned:
  #    scalar
  # Example:
  #    my $value = $Cookies->randCookie( Seed => $seed );
  my $Cookies = shift;                                     # Get Cookies object
  my %args    = @_;                                        # Get remaining arguments
  my $seed    = $args{Seed} || time;
  my $MD5     = Digest::MD5->new;
  my $random  = "";
  open( RANDOM, "/dev/random" );
  sysread( RANDOM, $random, 16 );
  close( RANDOM );
  $MD5->add( $random );
  $MD5->add( $seed );
  return( $MD5->hexdigest() );
}
