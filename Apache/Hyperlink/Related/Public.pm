#!/usr/local/bin/perl -w


package NetSoup::Apache::Hyperlink::Related::Public;
use Apache;
use Apache::Constants;
use Apache::URI;
use NetSoup::Autonomy::DRE::Query::HTTP;
@NetSoup::Apache::Hyperlink::Related::Public::ISA = qw();
1;


sub handler {
  my $r = shift;
  $r->content_type( "text/html" );
  $r->send_http_header();
  $r->print( qq(<table class="Sidebar" border="0" width="180" border="0" cellpadding="4" cellspacing="0">
                <tr class="header">
                <td class="header" height="24">Automatic Links</td>
                <td class="header" height="24" align="right" valign="center"><img src="/Widgets/Related/Logo.gif" alt="Powered by Autonomy"></td>
                </tr>) );
  &render( R        => $r,
           Database => "PressReleases",
           Heading  => "Related Press",
           Colour   => "lightgrey" );
  &render( R        => $r,
           Database => "General",
           Heading  => "Related Articles",
           Colour   => "lightgrey" );
  if( $r->uri() ) {
    $r->print( qq(<tr>
                  <td colspan="2" align="center" valign="center" style="border-top-style:solid;border-top-width:thin;border-top-color:#000000;">
                  <form method="GET" action="/Widgets/Retrieval/Results" style="margin-bottom:0px;padding-bottom:0px;">
                  <input type="hidden" name="m"      value="suggest" />
                  <input type="hidden" name="q"      value=") . $r->uri() . qq(" />
                  <input type="hidden" name="o"      value="useurl" />
                  <input type="image"  name="submit" value="Suggest More..." src="/Widgets/RelatedArticles/Suggest.gif" border="0" />
                  </form>
                  </td>
                  </tr>) );
  }
  $r->print( qq(</table>) );
  return( OK );
}


sub render() {
  my %args     = @_;
  my $r        = $args{R};
  my $Database = $args{Database};
  my $Heading  = $args{Heading};
  my $colour   = $args{Colour};
  my $URL      = $r->uri();
  my $DRE      = NetSoup::Autonomy::DRE::Query::HTTP->new( Caching  => $r->dir_config( "CACHING" ) || 0,
                                                           Period   => $r->dir_config( "PERIOD" )  || 120,
                                                           Hostname => $r->dir_config( "HOSTNAME" ),
                                                           Port     => $r->dir_config( "PORT" ) );
  $DRE->query( QMethod   => "s",
               QueryText => $URL,
               QNum      => 3,
               Database  => $Database,
               XOptions  => "useurl" );
  $r->print( qq(<tr class="SidebarSubTitle"><td colspan="2" height="24" class="SidebarSubTitle">$Heading</td></tr>\n) );
  if( $DRE->numhits() != 0 ) {
  RENDER: for( my $i = 1 ; $i <= $DRE->numhits() ; $i++ ) {
      my $url    = $DRE->field( Index => $i, Field => "doc_name" );
      my $title  = $DRE->field( Index => $i, Field => "url_title" );
      my $weight = $DRE->field( Index => $i, Field => "doc_weight" );
      chomp( $weight ) if ( $weight );
      next RENDER if( ( ! $url )    ||
                      ( ! $title )  ||
                      ( ! $weight ) ||
                      ( $url eq $r->uri() ) );
      $r->print( qq(<tr class="$colour"><td colspan="2" height="24" class="SidebarItem">
                    <a class="Sidebar" href="$url">$title</a>
                    </td></tr>\n) );
    }
  } else {
    $r->print( qq(<tr class="$colour"><td colspan="2" height="24" class="SidebarItem">
                  <p>No related documents</p>
                  </td></tr>\n) );
  }
  return(1);
}
