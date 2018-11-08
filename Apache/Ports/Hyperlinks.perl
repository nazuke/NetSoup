#!/usr/local/bin/perl -w -I/usr/local/apache/lib

use strict;
use dre;
use NetSoup::CGI;
use NetSoup::Protocol::HTTP;


{
	$|                = 1;
	my $r             = shift;
	my $CGI           = NetSoup::CGI->new();
	my $REQUEST_URI   = $ENV{REQUEST_URI};
  my ( $CALLERURI ) = ( $REQUEST_URI =~ m/\?CALLERURI=([^\&]+)(\..html)/ );
	print( "Content-Type: text/html\r\n\r\n" );
	if( $CALLERURI ) {
		$CALLERURI   =~ s/index$//;
		$REQUEST_URI = $CALLERURI;
		print( qq(<!-- RELATED: "$REQUEST_URI" -->) );
	}
	print( qq(<table class="Sidebar" border="0" width="180" border="0" cellpadding="4" cellspacing="0">
						<tr class="header">
						<td class="header" height="24">Automatic Links</td>
						<td class="header" height="24" align="right" valign="center"><img src="/Widgets/Related/Logo.gif" alt="Powered by Autonomy"></td>
						</tr>) );
	&render( R           => $r,
					 Database    => "General",
           Relevance   => 25,
					 Heading     => "Related Articles",
					 Colour      => "lightgrey",
					 REQUEST_URI => $REQUEST_URI );
	&render( R           => $r,
					 Database    => "DOWNLOADABLES",
           Relevance   => 10,
					 Heading     => "Related Collateral",
					 Colour      => "lightgrey",
					 REQUEST_URI => $REQUEST_URI );
	&render( R           => $r,
					 Database    => "PressReleases",
           Relevance   => 30,
					 Heading     => "Related Press",
					 Colour      => "lightgrey",
					 REQUEST_URI => $REQUEST_URI );
=pod
	if( $REQUEST_URI ) {
		print( qq(<tr>
							<td colspan="2" align="center" valign="center" style="border-top-style:solid;border-top-width:thin;border-top-color:#000000;">
							<form method="GET" action="/Widgets/Retrieval/Results.shtml" style="margin-bottom:0px;padding-bottom:0px;">
							<input type="hidden" name="m"      value="suggest" />
							<input type="hidden" name="q"      value="$REQUEST_URI" />
							<input type="hidden" name="o"      value="useurl" />
							<input type="image"  name="submit" value="Suggest More..." src="/Widgets/Related/Suggest.gif" border="0" />
							</form>
							</td>
							</tr>) );
	}
=cut
	print( qq(</table>) );
}


sub render() {
	my %args      = @_;
	my $DRE_IP    = "192.168.2.16";
	my $r         = $args{R};
	my $Database  = $args{Database};
	my $Relevance = $args{Relevance} || 25;
	my $Heading   = $args{Heading};
	my $colour    = $args{Colour};
	my $HTTP      = NetSoup::Protocol::HTTP->new();
	my $URL       = $HTTP->escape( URL => "http://www.autonomy.com" . $args{REQUEST_URI} );
  dre::autonomyInit();
	dre::internalDreInit( 0, $DRE_IP, 60000, 60001);
	my $DRE        = dre::new_t_dre();
	my $DRE_Result = dre::new_t_dreQueryResult();
	my @ret        = ();
	dre::t_dre_create( $DRE, $DRE_IP, 60000, 60001 );
	print( qq(<tr class="SidebarSubTitle"><td colspan="2" height="24" class="SidebarSubTitle">$Heading</td></tr>\n) );
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
	print( "<!-- $URL $numhits -->" );
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
			print( qq(<tr class="$colour"><td colspan="2" height="24" class="SidebarItem">
                <table><tr>
                <td valign="top"><img src="$icon" /><br />$weight</td>
                <td><a class="Sidebar" href="$docname" target="$target">$title</a></td>
                </tr></table>
								</td></tr>\n) );
		}
	} else {
		print( qq(<tr class="$colour"><td colspan="2" height="24" class="SidebarItem" align="center">...</td></tr>\n) );
	}
	return(1);
}
