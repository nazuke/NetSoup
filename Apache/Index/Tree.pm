#!/usr/local/bin/perl -w

package NetSoup::Apache::Index::Tree;
use strict;
use Apache;
use Apache::Options;
use Apache::Constants qw( :http :response );
use Apache::URI;
use NetSoup::Files::Directory;
use NetSoup::XHTML::MenuMaker::Drivers;
use constant DIRECTORY => NetSoup::Files::Directory->new();
@NetSoup::Apache::Index::Tree::ISA = qw( NetSoup::Apache );
1;


sub handler {
  my $r = shift;
  if( $r->uri() =~ m:/$: ) {
    $r->send_http_header( 'text/html' );
    my $Tree = NetSoup::Apache::Index::Tree->new( R => $r, Enable => 1 );
    $Tree->render();
    $r->print( $Tree->{HTML} );
    return( OK );
  }
  return( DECLINED );
}


sub initialise {
  my $Tree        = shift;
  my %args        = @_;
  $Tree->{R}      = $args{R};
  $Tree->{URI}    = $args{URI}    || "";
  $Tree->{Enable} = $args{Enable} || 0;
  $Tree->{HTML}   = "";
  $Tree->{RECENT} = [];
  return( $Tree );
}


sub render {
  my $Tree       = shift;
  my %args       = @_;
  $Tree->{HTML} .= "<ul>\n";
  my $pathname   = $Tree->{R}->lookup_uri( $Tree->{URI} || $Tree->{R}->dir_config( "TREE_PATHNAME" ) )->filename();
  $Tree->scan( Path      => $pathname,
               FirstTime => 1 );
  $Tree->{HTML} .= "</ul>\n";
  if( @{$Tree->{RECENT}} ) {
    $Tree->{HTML} = "<ul>" . join( "", @{$Tree->{RECENT}} ) . "</ul>" . $Tree->{HTML};
  }
  return( $Tree->{HTML} );
}


sub scan {
  my $Tree     = shift;
  my %args     = @_;
  my $r        = $Tree->{R};
  my $path     = $args{Path};
  my $firstime = $args{FirstTime} || undef;
  my $time     = time;
  if( -d $path ) {
    return(1) if( $path =~ m/^\./ );
    my $dir_icon = $r->dir_config( "ICON_DIR" );
    $Tree->{HTML} .= qq(<li style="list-style-image:url($dir_icon)"><strong>) . DIRECTORY->filename( Pathname => $path ) . qq(</strong><ul>\n) if( ! defined $firstime );
    DIRECTORY->descend( Pathname    => $path,
                        Sort        => 1,
                        Recursive   => 0,
                        Files       => 1,
                        Directories => 1,
                        Callback    => sub {
                          my $pathname = shift;
                          my $filename = DIRECTORY->filename( Pathname => $pathname );
                          return(1) if( $filename =~ m/^\./ );
                          if ( -d $pathname ) {
                            $Tree->scan( Path => $pathname );
                          } else {
                            my $icon    = $r->dir_config( "ICON_DEFAULT" );
                            my ( $ext ) = ( $pathname =~ m/\.([^\.]+)$/ );
                            $icon       = $r->dir_config( "ICON_" . uc( $ext ) );
                            my $url     = $pathname;
                            my $prune   = $r->dir_config( "PRUNE" );
                            $url        =~ s/^$prune//;
                            $url        =~ s/[ ]/\%20/g;
                            my ( $dev,
                                 $ino,
                                 $mode,
                                 $nlink,
                                 $uid,
                                 $gid,
                                 $rdev,
                                 $size,
                                 $atime,
                                 $mtime,
                                 $ctime,
                                 $blksize,
                                 $blocks ) = stat( $pathname );
                            my $fsize  = $size / 1048576;
                            ( $fsize ) = ( $fsize =~ m/^([0-9]+\.[0-9]{2,2})/ );
                            if( $fsize < 1 ) {
                              $fsize = $fsize * 1024;
                              $fsize =~ s/\.[0-9]+$//;
                              $fsize = "$fsize KB";
                            } else {
                              $fsize = "$fsize MB";
                            }
                            my $newimage = "";
                            if( ( $time - $mtime ) <= int( $r->dir_config("NEWFILETIME") ) ) {
                              $newimage = $r->dir_config( "ICON_NEW" );
                              $newimage = qq(<img src="$newimage" /> );
                              if( $Tree->{Enable} ) {
                                push( @{$Tree->{RECENT}}, qq(<li style="list-style-image:url($icon)">${newimage}<a href="$url" target="_blank">$filename</a> - $fsize</li>\n) );
                              } else {
                                push( @{$Tree->{RECENT}}, qq(<li style="list-style-image:url($icon)">${newimage}$filename - $fsize</li>\n) );
                              }
                            }
                            if( $Tree->{Enable} ) {
                              $Tree->{HTML} .= qq(<li style="list-style-image:url($icon)">${newimage}<a href="$url" target="_blank">$filename</a> - $fsize</li>\n);
                            } else {
                              $Tree->{HTML} .= qq(<li style="list-style-image:url($icon)">${newimage}$filename - $fsize</li>\n);
                            }
                          }
                          return(1);
                        } );
    $Tree->{HTML} .= "</ul></li>\n" if( ! defined $firstime );
  }
  return(1);
}
