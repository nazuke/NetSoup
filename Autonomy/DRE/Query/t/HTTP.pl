#!/usr/local/bin/perl -w

use NetSoup::Autonomy::DRE::Query::HTTP;

my $DRE = NetSoup::Autonomy::DRE::Query::HTTP->new( Caching  => 0,
                                           Period   => ( 60 * 60 * 24 ),
                                           #Hostname => "registration.kenjin.com",
                                           Hostname => "www.autonomy.com",
                                           Port     => 60001 );
$DRE->query( QueryText => shift || "all things dead must rise again, when twilight\'s blanket falls",
             QNum      => 10,
             xDatabase  => "PressReleases" );
foreach my $field ( $DRE->fieldnames() ) {
  print( qq(FIELDNAME "$field"\n) );
}
for( my $i = 1 ; $i <= $DRE->numhits() ; $i++ ) {
  print( $DRE->field( Index => $i, Field => "url_title" ) );
}
exit(0);
