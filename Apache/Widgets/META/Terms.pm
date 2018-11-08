#!/usr/local/bin/perl -w

package NetSoup::Apache::Widgets::META::Terms;
use strict;
use Apache;
use Apache::Constants qw( :common :http :response );
use NetSoup::Autonomy::DRE::Query::t;
use NetSoup::Apache;
@NetSoup::Apache::Widgets::META::Terms::ISA = qw( NetSoup::Apache );
1;


sub handler {
  my $r   = shift;
  my $uri = NetSoup::Apache->new()->backref( $r );
  my $t   = NetSoup::Autonomy::DRE::Query::t->new( Hostname  => $r->dir_config( "HOST" ),
                                                   Port      => $r->dir_config( "PORT" ),
                                                   Querytext => $uri,
                                                   XOptions  => "useurl" );
  $r->send_http_header( "text/html" );
  $r->print( qq(<meta name="keywords" content=") . join( ", ", $t->terms() ) . qq(" />) );
  return( OK );
}
