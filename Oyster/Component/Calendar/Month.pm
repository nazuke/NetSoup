#!/usr/local/bin/perl
#
#   NetSoup::Oyster::Component::Calendar::Month.pm v00.00.01a 12042000
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


package NetSoup::Oyster::Component::Calendar::Month;
use strict;
use NetSoup::Oyster::Component;
use NetSoup::XML::DOM2::Core::Document;
use NetSoup::XML::DOM2::Traversal::Serialise;
use NetSoup::XML::DOM2::Traversal::TreeWalker;
use NetSoup::XHTML::Widgets::Table::text2table;
@NetSoup::Oyster::Component::Calendar::Month::ISA = qw( NetSoup::Oyster::Component );
my $DOCUMENT   = "NetSoup::XML::DOM2::Core::Document";
my $SERIALISE  = "NetSoup::XML::DOM2::Traversal::Serialise";
my $TREEWALKER = "NetSoup::XML::DOM2::Traversal::TreeWalker";
my $STYLESHEET = ""; #join( "", <NetSoup::Oyster::Component::Calendar::Month::DATA> );
1;


sub initialise {
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
  my $Month        = shift;                                                 # Get object
  my %args         = @_;                                                    # Get arguments
  $Month->{Time}   = $args{Time};
  $Month->{List}   = [];
  $Month->{Matrix} = [ [ "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun" ],             # What is "The Matrix"?
                       [ undef, undef, undef, undef, undef, undef, undef ],             # The Matrix stores a visual 'picture' of the month
                       [ undef, undef, undef, undef, undef, undef, undef ],
                       [ undef, undef, undef, undef, undef, undef, undef ],
                       [ undef, undef, undef, undef, undef, undef, undef ],
                       [ undef, undef, undef, undef, undef, undef, undef ] ];
  ( $Month->{Defaults}->{Weekday},
    $Month->{Defaults}->{Month},
    $Month->{Defaults}->{Day},
    $Month->{Defaults}->{Time},
    $Month->{Defaults}->{Year} ) = split( m/ +/, scalar localtime( $Month->{Time} ) );  # Sat Jan 27 17:10:33 2001
  my ( $weekday,
       $month,
       $day,
       $time,
       $year ) = split( m/ +/, scalar localtime( $Month->{Time} ) );                    # Sat Jan 27 17:10:33 2001
  unshift( @{$Month->{List}}, join( "\t", $weekday, $day, $month, $year ) );
  my $offset = $Month->{Time};
  my $flag   = 0;
  if( $day > 1 ) {
    while( ! $flag ) {                                                                    # Find first day of month
      $offset -= ( 60 * 60 * 24 );
      ( $weekday,
        $month,
        $day,
        $time,
        $year ) = split( m/ +/, scalar localtime( $offset ) );                            # Sat Jan 27 17:10:33 2001
      unshift( @{$Month->{List}}, join( "\t", $weekday, $day, $month, $year ) );
      $flag++ if( $day == 1 );
    }
  }
  $offset = $Month->{Time};
  $flag   = 0;
  while( ! $flag ) {                                                                    # Find last day of month
    $offset += ( 60 * 60 * 24 );
    ( $weekday,
      $month,
      $day,
      $time,
      $year ) = split( m/ +/, scalar localtime( $offset ) );                            # Sat Jan 27 17:10:33 2001
    if( $day == 1 ) {
      $flag++;
    } else {
      push( @{$Month->{List}}, join( "\t", $weekday, $day, $month, $year ) );
    }
  }
  my %Days = ( Mon => 0,
               Tue => 1,
               Wed => 2,
               Thu => 3,
               Fri => 4,
               Sat => 5,
               Sun => 6 );
  ( $weekday,
    $day,
    $month,
    $year ) = split( m/\t/, $Month->{List}->[0] );            # Sat Jan 27 17:10:33 2001
  my ( $X, $Y ) = ( $Days{$weekday}, 1 );             # Compute 1st weekday
  my $pointer   = 0;
  for( my $i = 0 ; $i < @{$Month->{Matrix}} ; $i++ ) {
    for( my $j = 0 ; $j < @{$Month->{Matrix}->[$i]} ; $j++ ) {
      if( $pointer < @{$Month->{List}} ) {
        ( $weekday,
          $day,
          $month,
          $year ) = split( m/\t/, $Month->{List}->[$pointer] );  # Sat Jan 27 17:10:33 2001
        $Month->{Matrix}->[$Y]->[$X] = $day;
        if( $X == 6 ) {
          $X = 0;
          $Y++;
        } else {
          $X++;
        }
        $pointer++;
      }
    }
  }
  return( $Month );
}


sub XML {
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
  my $Month  = shift;                                                 # Get object
  my %args   = @_;                                                    # Get arguments
  my $Matrix = $Month->{Matrix};
  my $XML    = "";
  my $DOM    = $Month->DOM( %args );
  if( defined $DOM ) {
    my $Serialise = $SERIALISE->new( Filter      => sub { return(1) },
                                     CurrentNode => $DOM,
                                     StrictSGML  => 1 );
    $Serialise->serialise( Node => $DOM, Target => \$XML );
  } else {
    return( undef );
  }
  return( $XML );
}


sub DOM {
  # This method...
  # Calls:
  #    none
  # Parameters Required:
  #    object
  #    hash    {
  #              Callback => { Tagname => sub {}, Tagname => sub {} ... }
  #            }
  # Result Returned:
  #    boolean
  # Example:
  #    method call
  my $Month      = shift;                                                 # Get object
  my %args       = @_;                                                    # Get arguments
  my $Callback   = $args{Callback} || undef;
  my $Matrix     = $Month->{Matrix};
  my $Text       = "";
  my $text2table = NetSoup::XHTML::Widgets::Table::text2table->new();
  for( my $i = 0 ; $i < @{$Matrix} ; $i++ ) {
    for( my $j = 0 ; $j < @{$Matrix->[$i]} ; $j++ ) {
      $Matrix->[$i]->[$j] = "" if( ! defined $Matrix->[$i]->[$j] );
      $Text .= $Matrix->[$i]->[$j] . "\t";
    }
    $Text .= "\n";
  }
  my $Table = $text2table->text2table( Content => $Text )->getWidget();
  if( defined $Table ) {
    my $Document   = $DOCUMENT->new();
    my $Fragment   = $Document->createDocumentFragment();
    my $TreeWalker = $TREEWALKER->new();
    my $DIV        = $Document->createElement( TagName => "div" );
    my $Container  = $Document->createElement( TagName => "table" );
    my $Row        = $Document->createElement( TagName => "tr" );
    my $Cell       = $Document->createElement( TagName => "td" );
    my $Style      = $Document->createElement( TagName => "style" );
    my $P          = $Document->createElement( TagName => "p" );


    $Container->setAttribute( Name => "class", Value => "Calendar_MonthContainer" );
    $P->setAttribute( Name => "class", Value => "Calendar_MonthHeader" );





    $Fragment->appendChild( NewChild => $DIV );
    $DIV->appendChild( NewChild => $Style );
    $Style->appendChild( NewChild => $Document->createTextNode( Data => $STYLESHEET ) );
    $DIV->appendChild( NewChild => $Container );
    $Container->appendChild( NewChild => $Row );
    $Row->appendChild( NewChild => $Cell );


    $Cell->appendChild( NewChild => $P );
    $P->appendChild( NewChild => $Document->createTextNode( Data => "$Month->{Defaults}->{Month} $Month->{Defaults}->{Year}" ) );


    $Cell->appendChild( NewChild => $Table );


    # The Callback argument is a hash of Tagnames and code references.
    # The code ref is called for each named element in the Month table.
    $TreeWalker->walkTree( Node => $Table,
                           Callback => sub {
                             my $Node = shift;
                           SWITCH: for( $Node->nodeName() ) {
                               m/^table$/i && do {
                                 $Node->setAttribute( Name => "border", Value => "0" );
                                 last SWITCH;
                               };
                               m/^td$/i && do {
                                 if( ( $Node->firstChild()->nodeType =~ m/TEXT_NODE/ ) &&
                                     ( $Node->firstChild()->nodeValue =~ m/^(Mon|Tue|Wed|Thu|Fri|Sat|Sun)$/i ) ) {
                                   $Node->setAttribute( Name => "class", Value => "Calendar_MonthCellWeek" );
                                 } else {
                                   $Node->setAttribute( Name => "class", Value => "Calendar_MonthCellDay" );
                                   if( defined $Callback->{TD} ) {
                                     &{$Callback->{TD}}( Document => $Document,
                                                         Node     => $Node );
                                   }
                                 }
                                 last SWITCH;
                               };
                             }
                             return(1);
                           } );


    return( $Fragment );
  }
  return( undef );
}


__DATA__

<!--

p {
  font-family: "Helvetica,Arial,Verdana";
  font-size:   9pt;
  text-align:  right;
}

table {
  border-width:     thin;
  border-style:     solid;
  border-color:     #805000;
  color:            #FFEEDD;
  background-color: #805000;
}

table.container {
  background-color: #445000;
}

td {
  font-family:      "Helvetica,Arial,Verdana";
  font-size:        8pt;
  font-weight:      bold;
  text-align:       right;
  color:            #000000;
  background-color: #DDAA33;
}

td.light {
  color:            #000000;
  background-color: #DDAA33;
}

td.dark {
  color:            #FFEEDD;
  background-color: #000000;
}

-->
