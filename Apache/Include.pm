#!/usr/local/bin/perl -w
# This Apache module performs server-side includes on a chunk of text.

package NetSoup::Apache::Include;
use strict;
use Apache::Constants;
use LWP::Simple;
@NetSoup::Apache::Include::ISA = qw();
1;


sub handler {
  my $r = shift;
  return( OK );
}


sub include {
  my %args     = @_;
  my $r        = $args{R};
  my $HTML     = $args{HTML};
  my ( $tag )  = ( $HTML =~ m/(<!--.include virtual="[^"]+"-->)/gis );
  my $hostname = "localhost"; #$r->hostname();
  if( defined $tag ) {
    my ( $path ) = ( $tag =~ m/<!--.include virtual="([^"]+)"-->/gis );
    if( $path =~ m:^[^/]: ) {
      my $doc_root = $r->document_root();
      my $partial  = $r->filename();
      $partial     =~ s:/[^/]*$:/:;                           # Trim filename from path
      $partial     =~ s:^$doc_root(.+/)$:/$1:;                # Strip leading document root from partial path
      $path        = $partial . $path;                        # Affix include path to partial path
    }
    my $content = get( "http://$hostname$path" );
    if( defined $content ) {
      $HTML =~ s:\Q$tag\E:$content:s;                         # Merge fetched HTML with document
    }
    $HTML = include( R => $r, HTML => $HTML );
  }
  return( $HTML );
}


sub xinclude {
  my %args = @_;
  my $r    = $args{R};
  my $HTML = $args{HTML};
 INCLUDE: while( $HTML =~ m/<!--.(include|fsize) virtual=\"[^\"]+\"-->/gs ) {
  SWITCH: for( $1 ) {
      m/include/ && do {
        my ( $tag, $path ) = ( $HTML =~ m/(<!--.include virtual=\"([^\"]+)\"-->)/s );
        if( defined $path ) {
          if( $path =~ m:^[^/]: ) {
            my $doc_root = $r->document_root();
            my $partial  = $r->filename();
            $partial     =~ s:/[^/]*$:/:;             # Trim filename from path
            $partial     =~ s:^$doc_root(.+/)$:/$1:;  # Strip leading document root from partial path
            $path        = $partial . $path;          # Affix include path to partial path
          }
          my $content = get( "http://" . $r->hostname() . $path );
          if( defined $content ) {
            $HTML =~ s:\Q$tag\E:$content:s;       # Merge fetched HTML with document
          }
        } else {
          ;
        }
        last SWITCH;
      };
    }
  }
  return( $HTML );
}
