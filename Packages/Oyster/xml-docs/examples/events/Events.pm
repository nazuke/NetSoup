#!/usr/local/bin/perl -w

use NetSoup::Oyster::Component;
use NetSoup::Oyster::Component::Calendar;
use NetSoup::Files::Directory;

my $Calendar  = NetSoup::Oyster::Component::Calendar->new();
my $Directory = NetSoup::Files::Directory->new();
my %Dates     = ( 1  => {},
                  2  => {},
                  3  => {},
                  4  => {},
                  5  => {},
                  6  => {},
                  7  => {},
                  8  => {},
                  9  => {},
                  10 => {},
                  11 => {},
                  12 => {} );
$Directory->descend( Pathname    => $Box->directory(),
                     Directories => 0,
                     Files       => 1,
                     Recursive   => 1,
                     Callback    => sub {
                       my $pathname        = shift;
                       my $filename        = $Directory->filename( Pathname => $pathname );
                       my ( $month, $day ) = ( $filename =~ m/^([0-9]{2})([0-9]{2})\.shtml\...$/i );
                       if( $month ) {
                         $Document->registerSource( Source => $pathname );
                         $month    =~ s/^0?//;
                         $day      =~ s/^0?//;
                         $pathname =~ s/^$ENV{DOCUMENT_ROOT}//;
                         $pathname =~ s/\.shtml\...$//;
                         $Dates{$month}->{$day} = $pathname;
                       }
                     } );
my $alternate = 0;
my $thisMonth = $Calendar->thisMonth();
my $thisYear  = $Calendar->thisYear();
for( my $i = 1 ; $i <= 12 ; $i++ ) {
  if( $alternate == 0 ) {
    $Document->out( qq(<table border="0" cellspacing="4"><tr><td valign="top">) );
  } else {
    $Document->out( qq(<td valign="top">) );
  }
  my $Month = $Calendar->month( Year  => $thisYear,
                                Index => $thisMonth );
  $Document->out( $Month->XML( Callback => { TD => sub { 
                                               my %params = @_;
                                               my $Doc    = $params{Document};
                                               my $Node   = $params{Node};
                                               my $value  = $Node->firstChild()->nodeValue();
                                               if( defined $Dates{$thisMonth}->{$value} ) {
                                                 my $A = $Doc->createElement( TagName => "a" );
                                                 $A->setAttribute( Name => "class", Value => "Calendar_MonthCellDayLink" );
                                                 $A->setAttribute( Name => "href",  Value => "$Dates{$thisMonth}->{$value}" );
                                                 $A->appendChild( NewChild => $Node->firstChild() );
                                                 $Node->appendChild( NewChild => $A );
                                                 $Node->setAttribute( Name => "class", Value => "Calendar_MonthCellDayLink" );
                                                 $Node->removeChild( OldChild => $Node->firstChild() );
                                               }
                                             } } ) );
  if( $alternate == 0 ) {
    if( $i == 12 ) {
      $Document->out( qq(</td><td>&nbsp;</td></tr></table>) );
    } else {
      $Document->out( qq(</td>) );
    }
  } else {
    $Document->out( qq(</td></tr></table>) );
  }
  if( $alternate == 0 ) {
    $alternate = 1;
  } else {
    $alternate = 0;
  }
  $thisMonth++;
  if( $thisMonth == 13 ) {
    $thisMonth = 1;
    $thisYear++;
  }
}
