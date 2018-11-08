#!/usr/local/bin/perl -w
# This NetSoup Apache module inserts links to static documents into the HTML.

package NetSoup::Apache::Hyperlink::Static::Public;
use strict;
use Apache::Constants;
use NetSoup::Apache::Hyperlink;
use NetSoup::Apache::Include;
use NetSoup::Files::Load;
use NetSoup::Files::Cache;
use constant LOAD => NetSoup::Files::Load->new();
@NetSoup::Apache::Hyperlink::Static::Public::ISA = qw( NetSoup::Apache::Hyperlink );
1;


sub access {
  my $r           = shift;
  $ENV{CALLERURI} = $r->uri();
  return( OK );
}


sub handler {
  my $r     = shift;
  my $Cache = NetSoup::Files::Cache->new();
  if( -e $r->dir_config( "STRINGS" ) ) {
    if( $r->dir_config( "USECACHE" ) eq "true" ) {
      my @source_stat  = stat( $r->filename() );
      my @strings_stat = stat( $r->dir_config( "STRINGS" ) );
      my @cache_stat   = stat( $Cache->cache_path( Descriptor => $r->filename() ) );
      if( $cache_stat[9] >= $strings_stat[9] ) {
        if( -e $Cache->cache_path( Descriptor => $r->filename() ) ) {
          $r->content_type( "text/html" );
          $r->send_http_header();
          $r->print( $Cache->load_cache( Descriptor => $r->filename() ) );
          return( OK );
        }
      }
    }
    my $HTML = NetSoup::Apache::Hyperlink::staticlink( R => $r, Strings => \&strings );
    $HTML    = NetSoup::Apache::Include::include( R => $r, HTML => $HTML );
    $r->content_type( "text/html" );
    $r->send_http_header();
    if( defined $HTML ) {
      $r->print( $HTML );
      if( $r->dir_config( "USECACHE" ) eq "true" ) {
        $Cache->save_cache( Descriptor => $r->filename(),
                            Data       => $HTML );
      }
      return( OK );
    } else {
      return( 500 );
    }
  } else {
    return( 500 );
  }
}


sub strings {
  # This method returns the array of key/value pairs
  my %args = @_;
  my $r    = $args{R};
  if( ! -e $r->dir_config( "STRINGS" ) ) {
    print( STDERR qq(STRINGS ") . $r->dir_config( "STRINGS" ) . qq(" File not Found\n) );
    return( undef );
  }
  return( split( m/[\r\n]/, LOAD->immediate( Pathname => $r->dir_config( "STRINGS" ) ) ) );
}
