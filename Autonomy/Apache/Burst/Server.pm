#!/usr/local/bin/perl -w

package NetSoup::Autonomy::Apache::Burst::Server;
use Apache;
use Apache::Constants;
use Apache::URI;
use NetSoup::CGI;
@NetSoup::Autonomy::Apache::Burst::Server::ISA = qw();
1;


sub handler {
  my $r     = shift;
  my $Burst = NetSoup::Autonomy::DRE::Query::Burst->new( Caching  => 1,
                                                Period   => ( 60 * 60 * 24 ),
                                                Hostname => "193.115.251.53",
                                                Port     => 60000 );
  my $CGI = NetSoup::CGI->new();
  my $query = $CGI->field( Name   => "q",
                           Format => "ascii" );
  
  

  $Burst->mquery_server( Queries => \@queries,
                         QNum    => 6 );


foreach my $query ( @queries ) {
  
  
  foreach my $field ( $Burst->fieldnames( Query => $query ) ) {
    print( qq(FIELDNAME "$field"\n) );
  }
  
  
  for( my $i = 1 ; $i <= $Burst->numhits( Query => $query ) ; $i++ ) {
    print( $Burst->field( Query => $query,
                          Index => $i,
                          Field => "url_title" )  . "\n" );
  }
  
  
}



  $r->content_type( "text/plain" );
  $r->send_http_header();
  $r->print( $Burst->packet() );
  return( OK );
}
