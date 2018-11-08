#!/usr/local/bin/perl -w

package NetSoup::Apache::Images::Random;
use strict;
use Apache::Constants;
use Apache::URI;
use NetSoup::Maths::Entropy;
use NetSoup::Files::Directory;
use NetSoup::Files::Load;
@NetSoup::Apache::Images::Random::ISA = qw( NetSoup::Maths::Entropy
                                            NetSoup::Files::Directory
                                            NetSoup::Files::Load );
1;


sub handler {
  my $r         = shift;
  my $subr      = $r->lookup_uri( $r->uri() );
  my $Random    = NetSoup::Apache::Images::Random->new();
  my @images    = ();
  my $pathname  = $subr->filename();
  ( $pathname ) = ( $pathname =~ m/^(.+)\/$/ );
  $Random->descend( Pathname    => $subr->filename(),
                    Files       => 1,
                    Directories => 0,
                    Recursive   => 0,
                    Extensions  => [ "gif", "jpg" ],
                    Callback    => sub {
                      my $path = shift;
                      push( @images, $path );
                    } );
  $pathname = $images[$Random->random( Max => int @images )];
  if( $pathname =~ m/\.gif$/ ) {
    $r->content_type( 'image/gif' );
  } elsif( $pathname =~ m/\.jpg$/ ) {
    $r->content_type( 'image/jpeg' );
  }
  $r->send_http_header();
  $r->print( $Random->immediate( Pathname => $pathname ) );
  return( OK );
}
