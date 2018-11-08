#!/usr/local/bin/perl -w

use NetSoup::HTML::HTML2Text;
use NetSoup::Files::Load;

foreach my $pathname ( @ARGV ) {
  my $Load      = NetSoup::Files::Load->new();
  my $HTML2Text = NetSoup::HTML::HTML2Text->new();
  my $HTML      = "";
  my $Text      = "";
  $Load->load( Pathname => $pathname,
               Data     => \$HTML );
  $Text = $HTML2Text->html2text( HTML => $HTML,
                                 Wrap => 1 );
  if( $Text ) {
    print( STDOUT $Text );
  } else {
    print( STDERR "An Error Occurred\n" );
  }
}
exit(0);
