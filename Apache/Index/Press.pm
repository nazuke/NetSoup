#!/usr/local/bin/perl -w
# This Apache module generates a press release index.

package NetSoup::Apache::Index::Press;
use strict;
use Apache;
use Apache::Constants;
use Apache::URI;
use NetSoup::CGI;
use NetSoup::Files::Directory;
use NetSoup::Files::Load;
use constant DIRECTORY => NetSoup::Files::Directory->new();
use constant LOAD      => NetSoup::Files::Load->new();
@NetSoup::Apache::Index::Press::ISA = qw();
1;


sub handler {
  my $r        = shift;
  my $pathname = $r->filename();
  my $year     = DIRECTORY->filename( Pathname => $pathname );
  my @top      = ();
  return( DECLINED ) if( -f $pathname );
  $r->content_type( "text/html" );
  $r->send_http_header();
  $r->print( LOAD->immediate( Pathname => $r->document_root() . $r->dir_config( "PressHeader" ) ) );
  $r->print( qq(<script language="JavaScript">
                document.title = ") . $r->dir_config( "PressTitle" ) . qq( - $year";
                </script>) );
  $r->print( qq(<tr class=") . $r->dir_config( "PressStyleHeader" ) . qq("><td class=") . $r->dir_config( "PressStyleHeader" ) . qq(" height="24">
                Press Releases from $year
                </td></tr>) );
  DIRECTORY->descend( Pathname    => $pathname,
                      Sort        => 1,
                      Recursive   => 0,
                      Files       => 1,
                      Directories => 0,
                      Callback    => sub {
                        my $path     = shift;
                        my $filename = DIRECTORY->filename( Pathname => $path );
                        push( @top, $path ) if( $filename =~ m/^\d{4}[a-z]?\.s?html(\...)?$/ );
                        return(1);
                      } );
  my $class = "";
  my $count = 0;
 LIST: for( my $i = ( @top - 1 ) ; $i >= 0 ; $i-- ) {
    last LIST if( ! defined $top[$i] );
    my $data        = LOAD->immediate( Pathname => $top[$i] );
    my ( $title )   = ( $data =~ m:document.title = \"([^\"]+)\";:gis );
    my ( $summary ) = ( $data =~ m:<summary>[\n\r\t ]+<p>(.+)</p>[\n\r\t ]+</summary>:gis );
    my $root        = $r->document_root();
    my ( $url )     = ( $top[$i] =~ m/^\Q$root\E(.+)$/gis );
    
    my $prune       = $r->dir_config( "Prune" );
    $url            =~ s/^$prune//;
    
    
    
    if( $count == 0 ) {
      $class = qq( style="background-color:#) . $r->dir_config( "PressStyleLight" ) . qq(;");
      $count = 1;
    } else {
      $class = qq( style="background-color:#) . $r->dir_config( "PressStyleDark" ) . qq(;");
      $count = 0;
    }
    $r->print( qq(<tr$class><td>
                  <a href="$url">$title</a>
                  </td></tr>\n
                  <tr$class><td class=") . $r->dir_config( "PressStyleItem" ) . qq(">$summary</td></tr>\n) );
  }
  $r->print( LOAD->immediate( Pathname => $r->document_root() . $r->dir_config( "PressFooter" ) ) );
  return( OK );
}
