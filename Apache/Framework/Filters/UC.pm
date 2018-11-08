#!/usr/local/bin/perl -w

package NetSoup::Apache::Framework::Filters::UC;
use strict;
use NetSoup::Apache;
use NetSoup::XML::File;
use constant FILE => NetSoup::XML::File->new();
@NetSoup::Apache::Framework::Filters::UC::ISA = qw( NetSoup::Apache );
1;

sub filter {
  my $UC       = shift;
  my $r        = shift;
  my $content  = shift;
  my $Document = FILE->qparse( XML => $content );
  my $NodeList = $Document->getElementsByTagName( TagName => "TEXT_NODE" );
  for ( my $i = 0 ; $i < $NodeList->nodeListLength() ; $i++ ) {
    my $Node  = $NodeList->item( Item => $i );
    my $value = $Node->nodeValue();
    $Node->nodeValue( NodeValue => uc( $value ) );
  }
  return( FILE->serialise( Document   => $Document,
                           StrictSGML => 0,
                           Compact    => 1) );
}
