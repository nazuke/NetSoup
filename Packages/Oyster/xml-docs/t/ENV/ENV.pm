#!/usr/local/bin/perl

use NetSoup::XML::DOM2::Core::Document;
use NetSoup::XML::DOM2::Traversal::Serialise;

my $DOM       = NetSoup::XML::DOM2::Core::Document->new();
my $Serialise = NetSoup::XML::DOM2::Traversal::Serialise->new( Filter     => sub { return(1) },
                                                               StrictSGML => 1 );
my $Table     = $DOM->createElement( TagName => "table" );
my $HTML      = "";
$Table->setAttribute( Name => "border", Value => "1" );
foreach my $key ( sort( keys( %ENV ) ) ) {
  my $TR      = $DOM->createElement( TagName => "tr" );
  my $LeftTD  = $DOM->createElement( TagName => "td" );
  my $RightTD = $DOM->createElement( TagName => "td" );
  $LeftTD->appendChild( NewChild => $DOM->createTextNode( Data => $key ) );
  $RightTD->appendChild( NewChild => $DOM->createTextNode( Data => $ENV{$key} ) );
  $TR->appendChild( NewChild => $LeftTD );
  $TR->appendChild( NewChild => $RightTD );
  $Table->appendChild( NewChild => $TR );
}
$Serialise->serialise( Node => $Table, Target => \$HTML );
$Document->out( $HTML );
