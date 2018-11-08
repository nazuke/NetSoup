#!/usr/local/bin/perl -w -I/usr/local/apache/lib

use strict;
use dre;
use NetSoup::CGI;
use NetSoup::Protocol::HTTP;


{
	my $r          = shift;
  my $RequestURI = $r->header_in( "Referer" );
  my $JS         = "";
  $r->content_type( "text/javascript" );
  $r->send_http_header();
  if( defined $RequestURI ) {
    if( $r->header_in( "Host" ) =~ m/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/ ) {
      $RequestURI =~ s/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/www.autonomy.com/;
    }
    {
      my ( $flag, $string )= &render( R          => $r,
                                      Database   => "General",
                                      Relevance  => $r->dir_config( "HYPERLINKS_RELEVANCE_ARTICLES" ),
                                      Heading    => "Related Articles",
                                      Colour     => "lightgrey",
                                      RequestURI => $RequestURI );
      if( $flag != 0 ) {
        $JS .= $string;
      }
    }
    {
      my ( $flag, $string )= &render( R          => $r,
                                      Database   => "DOWNLOADABLES",
                                      Relevance  => $r->dir_config( "HYPERLINKS_RELEVANCE_PDF" ),
                                      Heading    => "Related Collateral",
                                      Colour     => "lightgrey",
                                      RequestURI => $RequestURI );
      if( $flag != 0 ) {
        $JS .= $string;
      }
    }
    {
      my ( $flag, $string )= &render( R          => $r,
                                      Database   => "PressReleases",
                                      Relevance  => $r->dir_config( "HYPERLINKS_RELEVANCE_PRESS" ),
                                      Heading    => "Related Press",
                                      Colour     => "lightgrey",
                                      RequestURI => $RequestURI );
      if( $flag != 0 ) {
        $JS .= $string;
      }
    }
    if( $JS ) {
      $r->print( qq(document.write('<table class="Sidebar" border="0" width="180" border="0" cellpadding="4" cellspacing="0">');\n) );
      $r->print( qq(document.write('<tr class="header"><td class="header" height="24">Automatic Links</td>');\n) );
      $r->print( qq(document.write('<td class="header" height="24" align="right" valign="center"><img src="/Widgets/Related/Logo.gif" alt="Powered by Autonomy"></td></tr>');\n) );
      $r->print( $JS );
      $r->print( qq(document.write('</table>');\n) );
    } else {
      $r->print( qq(document.write('<!--NOLINKS-->');\n) );
    }
  } else {
    $r->print( qq(document.write('<!--NOLINKS-->');\n) );
  }
}


sub render() {
	my %args      = @_;
	my $r         = $args{R};
	my $Database  = $args{Database};
	my $Relevance = $args{Relevance} || 25;
	my $Heading   = $args{Heading};
	my $colour    = $args{Colour};
	my $HTTP      = NetSoup::Protocol::HTTP->new();
	my $URL       = $HTTP->escape( URL => $args{RequestURI} );
  my $JS        = "";
  dre::autonomyInit();
  dre::internalDreInit( 0,
                        $r->dir_config( "HYPERLINKS_DRE_IP" ),
                        $r->dir_config( "HYPERLINKS_DRE_QUERY_PORT" ),
                        $r->dir_config( "HYPERLINKS_DRE_INDEX_PORT" ) );
	my $DRE        = dre::new_t_dre();
	my $DRE_Result = dre::new_t_dreQueryResult();
	dre::t_dre_create( $DRE,
                     $r->dir_config( "HYPERLINKS_DRE_IP" ),
                     $r->dir_config( "HYPERLINKS_DRE_QUERY_PORT" ),
                     $r->dir_config( "HYPERLINKS_DRE_INDEX_PORT" ) );
  dre::internalDreSuggest( 0,
													 $DRE_Result,
													 1,
													 $URL,
													 3,
													 "",
													 "",
													 "names=$Database",
													 "",
													 1,
													 $Relevance,
													 0 );
	my $numhits = dre::t_dreQueryResult_nResults_get( $DRE_Result );
  $JS    .= qq(document.write('<tr class="SidebarSubTitle"><td colspan="2" height="24" class="SidebarSubTitle">$Heading</td></tr>'););
  if( $numhits ) {
  RENDER: for( my $i = 0 ; $i < $numhits ; $i++ ) {
			my $result  = dre::t_dreQueryResult_get( $DRE_Result, $i );
			my $title   = dre::t_dreQueryResultRecord_szUrlTitle_get( $result );
      $title      =~ s/\'/\\\'/g;
      my $docname = dre::t_dreQueryResultRecord_szDocName_get( $result );
			my $nFields = dre::t_dreQueryResultRecord_nFields_get( $result );
			my $icon    = "article";
			my $weight  = dre::t_dreQueryResultRecord_nDocWeight_get( $result ) . '%';
      for( my $j = 0; $j < $nFields; $j++ ) {
        my $field = dre::t_dreQueryResultRecord_getfield( $result, $j );
        my $value = dre::t_dreQueryResultRecord_getvalue( $result, $j );
        if( $field =~ "SmallSiteImage" ) {
          $icon = $value;
				}
      }
			my $subr   = $r->lookup_uri( $docname );
			my $target = "_self";
			if( $subr->content_type() eq 'application/pdf' ) {
				$target = "_blank";
			}
			$JS .= qq(document.write('<tr class="$colour"><td colspan="2" height="24" class="SidebarItem">');\n);
      $JS .= qq(document.write('<table><tr>');\n);
      $JS .= qq(document.write('<td valign="top"><img src="$icon" /><br />$weight</td>');\n);
      $JS .= qq(document.write('<td><a class="Sidebar" href="$docname" target="$target">$title</a></td>');\n);
      $JS .= qq(document.write('</tr></table>');\n);
      $JS .= qq(document.write('</td></tr>');\n);
		}
	} else {
		$JS .= qq(document.write('<tr class="$colour"><td colspan="2" height="24" class="SidebarItem" align="center">...</td></tr>');\n);
	}
	return( $numhits, $JS );
}
