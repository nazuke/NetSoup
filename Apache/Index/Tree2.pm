#!/usr/local/bin/perl -w

package NetSoup::Apache::Index::Tree2;
use strict;
use Apache;
use Apache::Options;
use Apache::Constants qw( :http :response );
use Apache::URI;
use NetSoup::Files::Directory;
use NetSoup::XHTML::MenuMaker::Drivers;
use constant DIRECTORY => NetSoup::Files::Directory->new();
use constant WEEK      => 60 * 60 * 24 * 7;
@NetSoup::Apache::Index::Tree2::ISA = qw( NetSoup::Apache );
1;


sub handler {
  my $r = shift;
  if( $r->uri() =~ m:/$: ) {
    $r->send_http_header( 'text/html' );
    my $Tree2 = NetSoup::Apache::Index::Tree2->new( R => $r );
    $Tree2->render();
    $r->print( $Tree2->{HTML} );
    return( OK );
  }
  return( DECLINED );
}


sub initialise {
  my $Tree2         = shift;
  my %args          = @_;
  $Tree2->{R}       = $args{R};
  $Tree2->{URI}     = $args{URI}     || "";
  $Tree2->{Enable}  = $args{Enable}  || 0;
  $Tree2->{ShowNew} = $args{ShowNew} || 0;
  $Tree2->{HTML}    = "";
  $Tree2->{RECENT}  = [];
  return( $Tree2 );
}


sub render {
  my $Tree2       = shift;
  my %args        = @_;
  $Tree2->{HTML} .= "<ul>\n";
  my $pathname    = $Tree2->{R}->lookup_uri( $Tree2->{URI} || $Tree2->{R}->dir_config( "TREE_PATHNAME" ) )->filename();
  $Tree2->scan( Path      => $pathname,
                FirstTime => 1 );
  $Tree2->{HTML} .= "</ul>\n";
  if( @{$Tree2->{RECENT}} ) {
    $Tree2->{HTML} = "<ul>" . join( "", @{$Tree2->{RECENT}} ) . "</ul>" . $Tree2->{HTML};
  }
  return( $Tree2->{HTML} );
}


sub scan {
  my $Tree2     = shift;
  my %args     = @_;
  my $r        = $Tree2->{R};
  my $path     = $args{Path};
  my $firstime = $args{FirstTime} || undef;
  my $time     = time;
  if( -d $path ) {
    return(1) if( $path =~ m/^\./ );
    my $dir_icon = $r->dir_config( 'ICON_DIR' );
    $Tree2->{HTML} .= qq(<li style="list-style-image:url($dir_icon)"><strong>) . DIRECTORY->filename( Pathname => $path ) . qq(</strong><ul>\n) if( ! defined $firstime );
    DIRECTORY->descend( Pathname    => $path,
                        Sort        => 0,
                        NSort       => 1,
                        Recursive   => 0,
                        Files       => 1,
                        Directories => 1,
                        Callback    => sub {
                          my $pathname = shift;
                          my $filename = DIRECTORY->filename( Pathname => $pathname );
                          return(1) if( $filename =~ m/^\./ );
                          if ( -d $pathname ) {
                            $Tree2->scan( Path => $pathname );
                          } else {
                            my $icon    = $r->dir_config( 'ICON_DEFAULT' );
                            my ( $ext ) = ( $pathname =~ m/\.([^\.]+)$/ );
                            $icon       = $r->dir_config( 'ICON_' . uc( $ext ) );
                            my $url     = $pathname;
                            my $prune   = $r->dir_config( "DOWNLOADS_PRUNE" );
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
                            if( ( $time - $mtime ) <= WEEK ) {
                              $newimage = $r->dir_config( 'ICON_NEW' );
                              if( $Tree2->{ShowNew} == 1 ) {
                                if( $Tree2->{Enable} ) {
                                  push( @{$Tree2->{RECENT}}, qq(<li style="list-style-image:url($icon)">XX${newimage}<a href="$url" target="_blank">$filename</a> - $fsize</li>\n) );
                                } else {
                                  push( @{$Tree2->{RECENT}}, qq(<li style="list-style-image:url($icon)">${newimage}$filename - $fsize</li>\n) );
                                }
                              }
                            }


                            if( $Tree2->{Enable} ) {
                              $Tree2->{HTML} .= qq(<li style="list-style-image:url($icon)">${newimage}<a href="$url" target="_blank">$filename</a> - $fsize</li>\n);
                            } else {
                              $Tree2->{HTML} .= qq(<li style="list-style-image:url($icon)">${newimage}$filename - $fsize</li>\n);
                            }
                          }
                          return(1);
                        } );
    $Tree2->{HTML} .= "</ul></li>\n" if( ! defined $firstime );
  }
  return(1);
}
