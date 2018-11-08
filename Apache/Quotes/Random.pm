#!/usr/local/bin/perl -w

package NetSoup::Apache::Quotes::Random;
use strict;
use Apache::URI;
use NetSoup::Maths::Entropy;
use NetSoup::Files::Directory;
use NetSoup::Files::Load;
@NetSoup::Apache::Quotes::Random::ISA = qw( NetSoup::Maths::Entropy
                                            NetSoup::Files::Directory
                                            NetSoup::Files::Load );
1;


sub initialise {
  my $Random = shift;
  my %args   = @_;
  return( $Random );
}


sub handler {
  my $r = shift;
  $r->content_type( 'text/html' );
  $r->send_http_header();
  print( NetSoup::Apache::Quotes::Random->new()->quote( Pathname => $r->document_root() . $r->uri() ) );
  return( "OK" );  
}


sub quote {
  my $Random       = shift;
  my %args         = @_;
  my @quotes       = ();
  my ( $pathname ) = ( $args{Pathname} =~ m/^(.+)\/$/ );
  $Random->descend( Pathname    => $args{Pathname},
                    Files       => 1,
                    Directories => 0,
                    Recursive   => 0,
                    Extensions  => [ "html" ],
                    Callback    => sub {
                      my $pathname = shift;
                      push( @quotes, $pathname ) if( $pathname =~ m/\.html$/i );
                    } );
  return( $Random->immediate( Pathname => $quotes[$Random->random( Max => int @quotes )] ) );
}
