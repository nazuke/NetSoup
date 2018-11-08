#!/usr/local/bin/perl -w -I/usr/local/apache/lib

use strict;
use dre;
use NetSoup::CGI;
use NetSoup::Protocol::HTTP;


{
	my $r             = shift;
	my $CGI           = NetSoup::CGI->new();
	my $REQUEST_URI   = $ENV{REQUEST_URI};
  my ( $CALLERURI ) = ( $REQUEST_URI =~ m/\?CALLERURI=([^\&]+)(\..html)/ );
  $r->send_http_header( "text/html" );
  if( $CALLERURI ) {
		$CALLERURI   =~ s/index$//;
		$REQUEST_URI = $CALLERURI;
	}
	$r->print( qq(<table class="Sidebar" border="0" width="180" border="0" cellpadding="4" cellspacing="0">
						    <tr class="header">
						    <td class="header" height="24">Automatic Links</td>
						    <td class="header" height="24" align="right" valign="center"><img src="/Widgets/Related/Logo.gif" alt="Powered by Autonomy"></td>
						    </tr>) );
	&render( R           => $r,
					 Database    => "General",
           Relevance   => $r->dir_config( "HYPERLINKS_RELEVANCE_ARTICLES" ),
					 Heading     => "Related Articles",
					 Colour      => "lightgrey",
					 REQUEST_URI => $REQUEST_URI );
	&render( R           => $r,
					 Database    => "DOWNLOADABLES",
           Relevance   => $r->dir_config( "HYPERLINKS_RELEVANCE_PDF" ),
					 Heading     => "Related Collateral",
					 Colour      => "lightgrey",
					 REQUEST_URI => $REQUEST_URI );
	&render( R           => $r,
					 Database    => "PressReleases",
           Relevance   => $r->dir_config( "HYPERLINKS_RELEVANCE_PRESS" ),
					 Heading     => "Related Press",
					 Colour      => "lightgrey",
					 REQUEST_URI => $REQUEST_URI );
	$r->print( qq(</table>) );
}


sub render() {
	my %args      = @_;
	my $r         = $args{R};
	my $Database  = $args{Database};
	my $Relevance = $args{Relevance} || 25;
	my $Heading   = $args{Heading};
	my $colour    = $args{Colour};
	my $HTTP      = NetSoup::Protocol::HTTP->new();
	my $URL       = $HTTP->escape( URL => "http://www.autonomy.com" . $args{REQUEST_URI} );
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
	$r->print( qq(<tr class="SidebarSubTitle"><td colspan="2" height="24" class="SidebarSubTitle">$Heading</td></tr>\n) );
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
	if( $numhits ) {
	RENDER: for( my $i = 0 ; $i < $numhits ; $i++ ) {
			my $result  = dre::t_dreQueryResult_get( $DRE_Result, $i );
			my $title   = dre::t_dreQueryResultRecord_szUrlTitle_get( $result );
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
			$r->print( qq(<tr class="$colour"><td colspan="2" height="24" class="SidebarItem">
                    <table><tr>
                    <td valign="top"><img src="$icon" /><br />$weight</td>
                    <td><a class="Sidebar" href="$docname" target="$target">$title</a></td>
                    </tr></table>
								    </td></tr>\n) );
		}
	} else {
		$r->print( qq(<tr class="$colour"><td colspan="2" height="24" class="SidebarItem" align="center">...</td></tr>\n) );
	}
	return(1);
}
