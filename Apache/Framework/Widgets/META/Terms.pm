#!/usr/local/bin/perl -w

package NetSoup::Apache::Framework::Widgets::META::Terms;
use strict;
use Apache;
use Apache::Constants qw( :common :http :response );
use NetSoup::Autonomy::DRE::Query::t;
use NetSoup::Apache;
@NetSoup::Apache::Framework::Widgets::META::Terms::ISA = qw( NetSoup::Apache );
1;


sub widget {
  my $Terms = shift;
  my $r     = shift;
  my $Node  = shift;
  my $t     = NetSoup::Autonomy::DRE::Query::t->new( Hostname  => $r->dir_config( "HOST" ),
                                                     Port      => $r->dir_config( "PORT" ),
                                                     Querytext => $r->uri(),
                                                     XOptions  => "useurl" );
  return( qq(<meta name="keywords" content=") . join( ", ", $t->terms() ) . qq(" />) );
}
