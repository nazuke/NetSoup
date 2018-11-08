#!/usr/local/bin/perl

package NetSoup::Apache::Framework::Widgets::TView;
use strict;
use Apache;
use Apache::Constants qw( :http :response );
use NetSoup::Apache;
@NetSoup::Apache::Framework::Widgets::TView::ISA = qw( NetSoup::Apache );
1;


sub widget {
  my $TView    = shift;
  my $r        = shift;
  my $Document = shift;
  my $string   = "";
  my $NodeList = $Document->getElementsByTagName( TagName => "tview" );
  for ( my $i = 0 ; $i < $NodeList->nodeListLength ; $i++ ) {
    my $Node    = $NodeList->item( Item => $i );
    
    my $package = $Node->getAttribute( Name => "package" );
    my $method  = $Node->getAttribute( Name => "method" ) || "widget";
    
    my $content = $package->$method( $r, $Node );
    
    my $Text    = $Document->createTextNode( Data => $content );
    $Node->parentNode()->insertBefore( RefChild => $Node, NewChild => $Text );
    $Node->parentNode()->removeChild( OldChild => $Node );
  }
  return( $string );
}
