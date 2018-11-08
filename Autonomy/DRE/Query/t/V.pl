#!/usr/local/bin/perl -w

use NetSoup::Autonomy::DRE::Query::V;


my $V = NetSoup::Autonomy::DRE::Query::V->new( Hostname => "registration.kenjin.com",
                                      Port     => 60000 );


foreach my $conf_field ( $V->conf_fields() ) {
  #print( qq($conf_field: ") . $V->conf_field( Name => $conf_field ) . qq("\n) );
}


foreach my $db ( $V->databases() ) {
  print( qq(Database: "$db"\n) );
  print( qq(    Docs: ") . $V->num_docs( Name => $db ) . qq("\n) );
  print( "\n" );
}


foreach my $dre_field ( $V->dre_fields() ) {
  print( qq($dre_field: ") . $V->dre_field( Name => $dre_field ) . qq("\n) );
}


exit(0);
