#!/usr/local/bin/perl -w

use NetSoup::Autonomy::DRE::Query::Burst;

my $Burst = NetSoup::Autonomy::DRE::Query::Burst->new( Caching  => 1,
                                              Period   => ( 60 * 60 * 24 ),
                                              Hostname => "193.115.251.53",
                                              Port     => 60000 );
my @queries = @ARGV;


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


print( $Burst->packet() );
exit(0);
