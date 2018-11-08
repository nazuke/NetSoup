#!/usr/local/bin/perl
#
#   NetSoup::Util::Time.pm v00.00.01g 12042000
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
#   Description: This Perl module provides simple time calculation methods.
#
#
#   Methods:
#       minutes  -  This method returns the number of seconds in n minutes
#       hours    -  This method returns the number of seconds in n hours
#       days     -  This method returns the number of seconds in n days
#       weeks    -  This method returns the number of seconds in n weeks
#       years    -  This method returns the number of seconds in n years


package NetSoup::Util::Time;
use strict;
use NetSoup::Core;
@NetSoup::Util::Time::ISA = qw( NetSoup::Core );
1;


sub minutes {
  # This method returns the number of seconds in n minutes.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    integer
  # Result Returned:
  #    boolean
  # Example:
  #    my $minutes = $object->minutes( 10 );
  my $object = shift;      # Get object
  return( 60 * (shift) );  # Return computed minutes
}


sub hours {
  # This method returns the number of seconds in n hours.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    object
  #    integer
  # Result Returned:
  #    boolean
  # Example:
  #    my $hours = $object->hours( 10 );
  my $object = shift;                                # Get object
  return( ( 60 * $object->minutes(1) ) * (shift) );  # Return computed hours
}


sub days {
  # This method returns the number of seconds in n days.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    object
  #    integer
  # Result Returned:
  #    boolean
  # Example:
  #    my $days = $object->days( 10 );
  my $object = shift;                              # Get object
  return( ( 24 * $object->hours(1) ) * (shift) );  # Return computed days
}


sub weeks {
  # This method returns the number of seconds in n weeks.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    object
  #    integer
  # Result Returned:
  #    boolean
  # Example:
  #    my $weeks = $object->weeks( 10 );
  my $object = shift;                            # Get object
  return( ( 7 * $object->days(1) ) * (shift) );  # Return computed weeks
}


sub years {
  # This method returns the number of seconds in n years.
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    object
  #    integer
  # Result Returned:
  #    boolean
  # Example:
  #    my $years = $object->years( 10 );
  my $object = shift;                              # Get object
  return( ( 365 * $object->days(1) ) * (shift) );  # Return computed years
}







sub format_date {
  my $date   = shift;
  my %Months = ( '01' => "January",
                 '02' => "February",
                 '03' => "March",
                 '04' => "April",
                 '05' => "May",
                 '06' => "June",
                 '07' => "July",
                 '08' => "August",
                 '09' => "September",
                 '10' => "October",
                 '11' => "November",
                 '12' => "December" );
  $date =~ s/^([0-9]+).([0-9]+).([0-9]+)$/$3\&nbsp;$Months{$2}\&nbsp;$1/;
  return( $date );
}


sub format_time {
  my $time              = shift;
  my ( $hour,$minutes ) = split( /:/, $time );
  my $postfix           = "";
  $hour                 =~ s/^[0]//;
  if( $hour <= 11 ) {
    $postfix = '&nbsp;AM';
  } else {
    $hour -= 12 if( $hour > 12 );
    $postfix = '&nbsp;PM';
  }
  return( "$hour:$minutes$postfix" );
}
