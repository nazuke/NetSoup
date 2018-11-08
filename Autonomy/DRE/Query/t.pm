#!/usr/local/bin/perl -w


package NetSoup::Autonomy::DRE::Query::t;
use strict;
use LWP::Simple qw( get );
use NetSoup::Core;
@NetSoup::Autonomy::DRE::Query::t::ISA = qw( NetSoup::Core );
1;


sub initialise {
  my $t           = shift;
  my %args        = @_;
  $t->SUPER::initialise( %args );
    
  $t->{Caching}   = $args{Caching} || 0;     # Caching flag
  $t->{Period}    = $args{Period}  || 3600;  # Caching period, default one hour
  
  $t->{NumHits}   = 0;
  $t->{Terms}     = [];
  $t->{Hostname}  = $args{Hostname};
  $t->{Port}      = $args{Port};
  $t->{Querytext} = $args{Querytext};
  $t->{XOptions}  = $args{XOptions};
  $t->{Document}  = get( "http://$t->{Hostname}:$t->{Port}/qmethod=t\&querytext=$t->{Querytext}\&xoptions=$t->{XOptions}" );
  my %state       = ( Key => 1 );
  my @terms       = split( m/[\r\n]+/s, $t->{Document} );
  if( @terms ) {
    ( $t->{NumHits} ) = ( $terms[0] =~ m/([0-9]+)$/ );
    for( my $i = 1 ; $i <= $t->{NumHits} ; $i++ ) {
      push( @{$t->{Terms}}, $terms[$i] );
    }
  } else {
    return( undef );
  }
  return( $t );
}


sub num_hits {
  my $t    = shift;
  my %args = @_;
  return( $t->{NumHits} );
}


sub terms {
  my $t    = shift;
  my %args = @_;
  return( @{$t->{Terms}} );
}
