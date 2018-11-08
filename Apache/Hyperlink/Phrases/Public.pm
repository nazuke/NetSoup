#!/usr/local/bin/perl -w
# This NetSoup Apache module performs DRE lookups on a list of phrases,
# and insert hyperlinks into the HTML.

package NetSoup::Apache::Hyperlink::Phrases::Public;
use Apache::Constants;
use NetSoup::Apache::Hyperlink;
use NetSoup::Files::Load;
@NetSoup::Apache::Hyperlink::Phrases::Public::ISA = qw( NetSoup::Apache::Hyperlink );
use constant LOAD => NetSoup::Files::Load->new();
1;


sub handler {
  my $r    = shift;
  my $HTML = NetSoup::Apache::Hyperlink::hyperlink( R       => $r,
                                                    Strings => \&strings );
  $r->content_type( "text/html" );
  $r->send_http_header();
  if( defined $HTML ) {
    $r->print( $HTML );
    return( OK );
  } else {
    return( 500 );
  }
}


sub strings {
  # This method builds the Burst request object.
  my %args    = @_;
  my $r       = $args{R};
  if( ! -e $r->dir_config( "STRINGS" ) ) {
    print( STDERR qq(STRINGS ") . $r->dir_config( "STRINGS" ) . qq(" File not Found\n) );
    return( undef );
  }
  return( split( m/[\r\n]/, LOAD->immediate( Pathname => $r->dir_config( "STRINGS" ) ) ) );
}
