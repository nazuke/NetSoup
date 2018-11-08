#!/usr/local/bin/perl
#
#   NetSoup::Oyster::Box.pm v00.00.01a 12042000
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


package NetSoup::Oyster::Box;
use strict;
use NetSoup::Core;
@NetSoup::Oyster::Box::ISA   = qw( NetSoup::Core );
@NetSoup::Oyster::Box::Files = ();
1;


sub initialise {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    Box
  #    hash    {
  #              Key => Value
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Box  = shift;  # Get object
  my %args = @_;     # Get arguments
  return( $Box );
}


sub script {
  # This method returns path of the PerlXML script file.
  # Calls:
  #    none
  # Parameters Required:
  #    Box
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Box  = shift;                 # Get Box object
  my %args = @_;                    # Get arguments
  return( $ENV{PATH_TRANSLATED} );  #
}


sub scheme {
  # This method returns the HTTP scheme of the current document.
  # Calls:
  #    none
  # Parameters Required:
  #    Box
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Box  = shift;                # Get Box object
  my %args = @_;                   # Get arguments
  if( exists( $ENV{HTTPS} ) &&
      ( $ENV{HTTPS} eq "on" ) ) {
    return( "https" );
  }
  return( "http" );
}


sub URI {
  # This method returns the URL of the current document, sans QUERY_STRING.
  # Calls:
  #    none
  # Parameters Required:
  #    Box
  #    hash    {
  #              Filename => "yes" | "no"
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Box      = shift;                                                 # Get Box object
  my %args     = @_;                                                    # Get arguments
  my $Filename = $args{Filename} || "yes";
  my $URI      = $Box->scheme() . "://$ENV{HTTP_HOST}$ENV{PATH_INFO}";  #
  if( $Filename eq "no" ) {
    ( $URI ) = ( $Box->URI() =~ m:^(.+/)[^/]+$: );                      # Get URI sans filename
  }
  return( $URI );
}


sub query {
  # This method returns the query string of the current document.
  # Calls:
  #    none
  # Parameters Required:
  #    Box
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Box  = shift;              # Get Box object
  my %args = @_;                 # Get arguments
  return( $ENV{QUERY_STRING} );  # Build URL
}


sub URL {
  # This method returns the absolute URL of the current document.
  # Calls:
  #    none
  # Parameters Required:
  #    Box
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Box  = shift;                             # Get Box object
  my %args = @_;                                # Get arguments
  return( $Box->URI() . "?" . $Box->query() );  # Build URL
}


sub directory {
  # This method returns the path containing the PXML script.
  # Note: There is no trailing slash.
  # Calls:
  #    none
  # Parameters Required:
  #    Box
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Box      = shift;  # Get object
  my %args     = @_;     # Get arguments
  my $pathname = "";
  if( exists $ENV{PATH_TRANSLATED} ) {
    ( $pathname ) = ( $ENV{PATH_TRANSLATED} =~ m:^(.+)(\\|/)([^\\]|[^/])+$: );
  } else {
    $pathname = ".";
  }
  return( $pathname );
}


sub tempdir {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    Box
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Box      = shift;                            # Get object
  my %args     = @_;                               # Get arguments
  my $pathname = "";
  if( exists( $ENV{SERVER_SOFTWARE} ) &&
      ( $ENV{SERVER_SOFTWARE} =~ m/Apache/i ) ) {  # Apache
    return( "/tmp" );
  } else {
    return( "c:/temp" );                           # IIS on NT
  }
  return( $pathname );
}


sub lockfile {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    Box
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Box      = shift;                               # Get object
  my %args     = @_;                                  # Get arguments
  my $pathname = $args{Pathname};
  my $lockfile = $pathname . ".lck";
  my $timeout  = $args{Timeout} || 60;
  my $flag     = 0;
 TIMEOUT: for( my $i = $timeout ; $i >= 0 ; $i-- ) {  #
    if( -e $lockfile ) {
      sleep(1);
    } else {
      $flag = 1;
      last TIMEOUT;
    }
  }
  if( $flag == 1 ) {
    open( LOCKFILE, ">" . $lockfile );
    push( @NetSoup::Oyster::Box::Files, $lockfile );
    print( LOCKFILE "LOCKFILE" );
    close( LOCKFILE );
    return(1);
  }
  return(0);
}


sub unlockfile {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    Box
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Box      = shift;                    # Get object
  my %args     = @_;                       # Get arguments
  my $pathname = $args{Pathname};
  my $lockfile = $pathname . ".lck";
  unlink( $lockfile ) if( -e $lockfile );  #
  return(0);
}


sub DESTROY {
  my $Box = shift;
  foreach my $pathname ( @NetSoup::Oyster::Box::Files ) {
    unlink( $pathname ) if( -e $pathname );
  }
  return(1);
}
