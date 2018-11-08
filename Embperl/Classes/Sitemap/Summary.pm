#!/usr/local/bin/perl

package NetSoup::Embperl::Classes::Sitemap::Summary;
use strict;
#use dre;
use NetSoup::Autonomy::DRE::Query::HTTP;
@NetSoup::Embperl::Classes::Sitemap::Summary::ISA = qw();
1;


sub summary {
  my $r       = shift;
  my $url     = shift;
  my $string  = "";
  my $DRE     = NetSoup::Autonomy::DRE::Query::HTTP->new( Caching  => 1,
                                                          Hostname => $r->dir_config( "DRE_HOST" ),
                                                          Port     => $r->dir_config( "DRE_QUERY_PORT" ) );
  $DRE->query( QMethod   => "q",
               QueryText => $url,
               QNum      => 1,
               XOptions  => "useurl" );
  if( $DRE->numhits() ) {
    $string = $DRE->field( Index => 1, Field => "summary" );
  }
  $r->warn( qq(URL: "$url" ) );
  return( $string );
}


sub xsummary {
  my $Summary = shift;
  my $r       = shift;
  my $url     = shift;
  my $string  = "";
  dre::autonomyInit();
  dre::internalDreInit( 0, $r->dir_config( "DRE_HOST" ), $r->dir_config( "DRE_QUERY_PORT" ), $r->dir_config( "DRE_INDEX_PORT" ) );
  my $DRE        = dre::new_t_dre();
  my $DRE_Result = dre::new_t_dreQueryResult();
  my @ret        = ();
  my $relevance  = 15;
  dre::t_dre_create( $DRE, $r->dir_config( "DRE_HOST" ), $r->dir_config( "DRE_QUERY_PORT" ), $r->dir_config( "DRE_INDEX_PORT" ) );
  dre::internalDreSuggest( 0,
                           $DRE_Result,
                           1,
                           $url,
                           3,
                           "",
                           "",
                           "names=",
                           "",
                           1,
                           $relevance,
                           0 );
  my $numhits = dre::t_dreQueryResult_nResults_get( $DRE_Result );
  if( $numhits ) {
    my $result  = dre::t_dreQueryResult_get( $DRE_Result, 0 );
    my $title   = dre::t_dreQueryResultRecord_szUrlTitle_get( $result );
    my $docname = dre::t_dreQueryResultRecord_szDocName_get( $result );
    my $nFields = dre::t_dreQueryResultRecord_nFields_get( $result );
    for( my $j = 0; $j < $nFields; $j++ ) {
      if( dre::t_dreQueryResultRecord_getfield( $result, $j ) =~ "Summary" ) {
        $string = dre::t_dreQueryResultRecord_getvalue( $result, $j );
      }
    }
  } else {
    ;
  }
  return( $string );
}
