#!/usr/local/bin/perl -w

package NetSoup::Apache::TweetiePie;
use strict;
use Apache;
use Apache::Constants qw( :common :http :response );
use NetSoup::Files::Load;
use NetSoup::Maths::Entropy;
use constant LOAD  => NetSoup::Files::Load->new();
use constant CHAOS => NetSoup::Maths::Entropy->new();
@NetSoup::Apache::TweetiePie::ISA = qw();
1;


sub random {
  # This handler despatches incoming requests to a randomly picked host.
  my $r    = shift;
  my @good = split( m/\n/s, LOAD->immediate( Pathname => $r->dir_config( "LASTGOOD" ) ) );
  my $max  = @good;
  my $i    = CHAOS->random( Max => $max );
  my ( $loadavg, $ip ) = split( m/\t/, $good[$i] );
  $r->header_out( Location => "http://$ip/" );
  return( REDIRECT );
}


sub loadavg {
  # This handler despatches incoming requests to the host with the lowest 5min loadavg.
  my $r   = shift;
  my @good  = split( m/\n/s, LOAD->immediate( Pathname => $r->dir_config( "LASTGOOD" ) ) );
  my $lowest = 0;
  my $host  = "";
  foreach my $entry ( @good ) {
    my ( $loadavg, $ip ) = split( m/\t/, $entry );
    $r->warn( "TEST: $ip : $lowest : $loadavg" );
    if( $host eq "" ) {
      $host  = $ip;
      $lowest = $loadavg;
    } else {
      if( $loadavg <= $lowest ) {
        $host  = $ip;
        $lowest = $loadavg;
      }
    }
  }
  $r->header_out( Location => "http://$host/" );
  return( REDIRECT );
}
