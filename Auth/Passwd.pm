#!/usr/local/bin/perl
#
#   NetSoup::Auth::Passwd.pm v00.00.01b 12042000
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
#       authorise  -  This method checks to see if a user is authorised


package NetSoup::Auth::Passwd;
use strict;
use NetSoup::Core;
@NetSoup::Auth::Passwd::ISA = qw( NetSoup::Core );
1;


sub authorise {
  # This method checks to see if a user is authorised on this machine.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Username  => $username
  #              Password  => $password
  #              Encrypted => 0 | 1
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $object           = shift;                                  # Get object
  my %args             = @_;                                     # Get arguments
  my $cryptic          = $args{Encrypted} || 0;
  my ($name, $passwd ) = getpwnam( $args{Username} );            # Consult /etc/passwd
  if( $cryptic ) {
    return(1) if( $args{Password} eq $passwd );                  # Validate encrypted password
  } else {
    my $salt = substr( $passwd, 0, 2 );                          # Get salt, borrowed from perlfunc
    return(1) if( crypt( $args{Password}, $salt ) eq $passwd );  # Validate unencrypted password
  }
  return(0);
}
