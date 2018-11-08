#!/usr/local/bin/perl -w


package NetSoup::Apache::Index::Latest;
use strict;
use Apache;
use Apache::Options;
use Apache::Constants;
use Apache::URI;
use NetSoup::CGI;
use NetSoup::Files::Directory;
use NetSoup::Files::Load;
use constant LOAD      => NetSoup::Files::Load->new();
use constant DIRECTORY => NetSoup::Files::Directory->new();
@NetSoup::Apache::Index::Latest::ISA = qw();
1;


sub handler {
  my $r         = shift;
  my $CGI       = NetSoup::CGI->new();
  my @years     = ();
  my @months    = qw( NULL Jan Feb Mar Apr May Jun July Aug Sep Oct Nov Dec );
  my @top       = ();
  my @topdates  = ();
  my $max       = 2;  # Maximum entries to show, counting from zero
  $r->content_type( "text/html" );
  $r->send_http_header();
  DIRECTORY->descend( Pathname    => $r->document_root() . $r->dir_config( "Archives" ),
                      Sort        => 1,
                      Recursive   => 0,
                      Files       => 0,
                      Directories => 1,
                      Callback    => sub {
                        my $pathname = shift;
                        my $filename = DIRECTORY->filename( Pathname => $pathname );
                        push( @years, $filename ) if( $filename =~ m/^\d{4}$/ );
                      } );
  for( my $i = 0 ; $i < @years ; $i++ ) {
    DIRECTORY->descend( Pathname    => $r->document_root() . $r->dir_config( "Archives" ) . "/$years[$i]",
                        Sort        => 1,
                        Recursive   => 0,
                        Files       => 1,
                        Directories => 0,
                        Callback    => sub {
                          my $pathname = shift;
                          my $filename = DIRECTORY->filename( Pathname => $pathname );
                          if( $filename =~ m/^\d{4}[a-z]?\..?html(\...)?$/i ) {
                            push( @top, $pathname );
                            my ( $month, $day ) = ( $filename =~ m/^(\d{2})(\d{2})[a-z]?\..?html(\...)?$/i );
                            my $affix           = "";
                          SWITCH: for( $day ) {
                              m/(4|5|6|7|8|9|0|11|12|13|14|15|16|17|18|19|20)$/ && do {
                                $affix = "th";
                                last SWITCH;
                              };
                              m/1$/ && do {
                                $affix = "st";
                                last SWITCH;
                              };
                              m/2$/ && do {
                                $affix = "nd";
                                last SWITCH;
                              };
                              m/3$/ && do {
                                $affix = "rd";
                                last SWITCH;
                              };
                            }
                            my $date = int($day) . "$affix " . $months[int($month)];
                            push( @topdates, $date );
                          }
                        } );
  }
  $max = ( @top - 1 ) if( ( @top - 1 ) < $max );
  $r->print( LOAD->immediate( Pathname => $r->document_root() . $r->dir_config( "LatestHeader" ) ) );
 LIST: for( my $i = ( @top - 1 ) ; $i >= ( ( @top - 1 ) - $max ) ; $i-- ) {
    last LIST if( ! defined $top[$i] );
    my $data      =  LOAD->immediate( Pathname => $top[$i] );
    my ( $title ) = ( $data =~ m:<h1[^>]*>([^<>]+)</h1>:gis );
    my $root      = $r->document_root();
    my ( $url )   = ( $top[$i] =~ m/^\Q$root\E(.+)$/gis );
    $url          =~ s:\.[^\./]+$::;
    
    
    my $prune       = $r->dir_config( "Prune" );
    $url            =~ s/^$prune//;
    print( qq(<tr><td height="24" class="SidebarItem">
              <strong>$topdates[$i]</strong>
              <a class="Sidebar" href="$url">$title</a>
              </td></tr>\n) );
  }
  $r->print( LOAD->immediate( Pathname => $r->document_root() . $r->dir_config( "LatestFooter" ) ) );
  return( OK );
}
