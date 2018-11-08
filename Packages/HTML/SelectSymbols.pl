#!/usr/local/bin/perl -w

use NetSoup::Protocol::HTTP;
use NetSoup::Files::Load;
use NetSoup::HTML::Parser::Simple;

my $Parser = NetSoup::HTML::Parser::Simple->new();
my $URI    = shift;
my $HTML   = "";
if( -e $URI ) {
  my $Load = NetSoup::Files::Load->new();
  $Load->load( Pathname => $URI,
               Data     => \$HTML );
} else {
  my $HTTP  = NetSoup::Protocol::HTTP->new();
  my $HTDOC = $HTTP->get( URL => $URI );
  $HTML     = $HTDOC->body();
}
if( length( $HTML ) > 0 ) {
  my $Document = $Parser->parse( XML => \$HTML );
  if( defined $Document ) {
    my @Symbols = $Document->symbols();
    foreach my $idx ( @ARGV ) {
      print( STDOUT $Symbols[$idx]->nodeValue() . "\n" );
    }
  } else {
    foreach my $error( $Parser->errors() ) {
      print( STDERR $error );
    }
  }
}
exit(0);
