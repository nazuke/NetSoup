#!/usr/local/bin/perl -w


use NetSoup::Protocol::HTTP;
use NetSoup::XML::Parser::Preprocessor;
use NetSoup::Files::Load;


my $Load         = NetSoup::Files::Load->new();
my $Preprocessor = NetSoup::XML::Parser::Preprocessor->new( CaseSensitive => "no",
                                                            ParseText     => "no" );
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
  if( $Preprocessor->preprocessor( XML => \$HTML ) ) {
    my $count = 0;
    foreach my $Symbol ( $Preprocessor->symbols() ) {
      my $padding = "_" x ( 8 - length( $count ) );
      print( "$count$padding" . $Symbol->nodeValue() . "\n" );
      $count++;
    }
  } else {
    foreach my $error( $Preprocessor->errors() ) {
      print( $error );
    }
  }
}
exit(0);
