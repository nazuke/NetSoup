#!/usr/local/bin/perl
#
#   NetSoup::Oyster::Component::Calendar.pm v00.00.01a 12042000
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


package NetSoup::Oyster::Component::Calendar;
use strict;
use NetSoup::Oyster::Component;
use NetSoup::Oyster::Component::Calendar::Month;
use NetSoup::Oyster::Component::Calendar::Year;
@NetSoup::Oyster::Component::Calendar::ISA = qw( NetSoup::Oyster::Component );
my $MONTH = "NetSoup::Oyster::Component::Calendar::Month";
my $YEAR  = "NetSoup::Oyster::Component::Calendar::Year";
1;


sub initialise {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Time => time()
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Calendar       = shift;  # Get Calendar object
  my %args           = @_;     # Get arguments
  $Calendar->{Time}  = $args{Time} || time;
  $Calendar->{Month} = [];
  for( my $i = 1 ; $i <= 12 ; $i++ ) {
    $Calendar->{Month}->[$i] = $Calendar->month( Index => $i );
  }
  return(1);
}


sub day {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Key => Value
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Calendar = shift;  # Get Calendar object
  my %args     = @_;     # Get arguments
  my $Time     = $args{Time} || $Calendar->{Time};

  return(1);
}


sub week {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Key => Value
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Calendar = shift;  # Get Calendar object
  my %args     = @_;     # Get arguments
  my $Time     = $args{Time} || $Calendar->{Time};

  return(1);
}


sub month {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              [ Year  => 1970 .. 2040 ]
  #              [ Index => 1 .. 12 ]
  #              [ Time  => time() ]
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Calendar = shift;                              # Get Calendar object
  my %args     = @_;                                 # Get arguments
  my $Time     = $args{Time}  || $Calendar->{Time};  #
  my $Year     = $args{Year}  || undef;
  my $Index    = $args{Index} || undef;
  if( ( defined $Year  ) || ( defined $Index) ) {
    $Time = $Calendar->findStartOfMonth( %args );    # Propagate arguments
  }
  return( $MONTH->new( Time => $Time ) );            # Return Month object
}


sub year {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Key => Value
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Calendar = shift;                                       # Get Calendar object
  my %args     = @_;                                          # Get arguments
  my $Time     = $args{Time} || $Calendar->{Time};            #
  my @Starts   = ();
  my $Year     = $args{Year} || undef;
  for( my $i = 1 ; $i <= 12 ; $i++ ) {
    $Starts[$i] = $Calendar->findStartOfMonth( Index => $i );
  }
  if( defined $Year ) {
    $Time = $Calendar->findStartOfYear( %args );              # Propagate arguments
  }
  return( $YEAR->new( Time => $Time, Starts => \@Starts ) );  # Return Year object
}


sub findStartOfYear {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              [ Year => 1970 - 2040 ]
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Calendar                                     = shift;                                           # Get Calendar object
  my %args                                         = @_;                                              # Get arguments
  my $Time                                         = $args{Time} || $Calendar->{Time};
  my ( $weekday,  $month,  $day,  $time,  $year )  = split( m/ +/, scalar localtime( $Time ) );
  my ( $_weekday, $_month, $_day, $_time, $_year ) = split( m/ +/, scalar localtime( $Time ) );
  while( int $year == int $_year ) {                                                                  # Count down in hours from start time
    $Time -= ( 60 * 60 );
    ( $_weekday, $_month, $_day, $_time, $_year ) = split( m/ +/, scalar localtime( $Time ) );
  }
  while( int $year > int $_year ) {                                                                   # Count back up in minutes
    $Time += 60;
    ( $_weekday, $_month, $_day, $_time, $_year ) = split( m/ +/, scalar localtime( $Time ) );
  }
  while( int $year == int $_year ) {                                                                  # Count down in seconds for final adjustment
    $Time -= 1;
    ( $_weekday, $_month, $_day, $_time, $_year ) = split( m/ +/, scalar localtime( $Time ) );
  }
  if( defined $args{Year} ) {
    if( $args{Year} > $year ) {                                                                       # Search forwards
      my $diff = $args{Year} - $year;
      $Time    = $Calendar->findStartOfYear( Time => time + ( $diff * ( 60 * 60 * 24 * 7 * 53 ) ) );
    } else {                                                                                          # Search backwards
      my $diff = $year - $args{Year};
      $Time    = $Calendar->findStartOfYear( Time => time - ( $diff * ( 60 * 60 * 24 * 7 * 53 ) ) );
    }
  }
  return( ++$Time );                                                                                  # Increment extra second
}


sub findStartOfMonth {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #                Index => 1 .. 12
  #              [ Time  => $time ]
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Calendar = shift;        # Get Calendar object
  my %args     = @_;           # Get arguments
  my $Index    = $args{Index} || 1;
  my $Time     = $Calendar->findStartOfYear( %args );          # Propagate arguments
  my $Start    = 0;
  my @names    = qw( DUMMY Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
  my $month    = $names[$Index];
  my ( $_weekday,
       $_month,
       $_day,
       $_time,
       $_year ) = split( m/ +/, scalar localtime( $Time ) );
  if( $Index > 1 ) {
    while( $_month ne $month ) {
      $Time += ( 60 * 60 * 24 );
      ( $_weekday, $_month, $_day, $_time, $_year ) = split( m/ +/, scalar localtime( $Time ) );
    }
  }
  return( $Time );
}


sub thisDay {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    object
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Calendar = shift;        # Get Calendar object
  my %args     = @_;           # Get arguments
  my ( $weekday,
       $month,
       $day,
       $time,
       $year ) = split( m/ +/, scalar localtime( time ) );
  return( $day );
}


sub thisMonth {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Time => time
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Calendar = shift;                                      # Get Calendar object
  my %args     = @_;                                         # Get arguments
  my $Time     = $args{Time} || time;
  my %names    = ( Jan => 1,  Feb => 2,  Mar => 3,
                   Apr => 4,  May => 5,  Jun => 6,
                   Jul => 7,  Aug => 8,  Sep => 9,
                   Oct => 10, Nov => 11, Dec => 12, );
  my ( $weekday,
       $month,
       $day,
       $time,
       $year ) = split( m/ +/, scalar localtime( $Time ) );  # Split human-readable time
  return( $names{$month} );
}


sub thisYear {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Time => time
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Calendar = shift;        # Get Calendar object
  my %args     = @_;           # Get arguments
  my $Time     = $args{Time} || time;
  my ( $weekday,
       $month,
       $day,
       $time,
       $year ) = split( m/ +/, scalar localtime( $Time ) );
  return( $year );
}
