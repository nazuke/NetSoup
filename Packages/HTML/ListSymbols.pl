#!/usr/local/bin/perl -w


use NetSoup::Protocol::HTTP;
use NetSoup::HTML::Parser::Simple;
use NetSoup::Files::Load;


my $Load   = NetSoup::Files::Load->new();
my $Parser = NetSoup::HTML::Parser::Simple->new();
foreach my $URI ( @ARGV ) {
  my $HTML = "";
  if( -e $URI ) {
    my $Load = NetSoup::Files::Load->new();
    $Load->load( Pathname => $URI,
                 Data     => \$HTML );
  } else {
    my $HTTP  = NetSoup::Protocol::HTTP->new();
    my $HTDOC = $HTTP->get( URL => $URI );
    $HTML     = $HTDOC->body();
  }
  my $Document = $Parser->parse( XML => \$HTML );
  if( defined $Document ) {
    my $count = 0;
    foreach my $Symbol ( $Document->symbols() ) {
      my $padding = "_" x ( 8 - length( $count ) );
      print( "$count$padding" . $Symbol->nodeValue() . "\n" );
      $count++;
    }
  } else {
    foreach my $error( $Parser->errors() ) {
      print( $error );
    }
  }
}
exit(0);
