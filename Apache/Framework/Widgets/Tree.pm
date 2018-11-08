#!/usr/local/bin/perl -w

package NetSoup::Apache::Framework::Widgets::Tree;
use strict;
use Apache;
use Apache::Options;
use Apache::Constants qw( :http :response );
use Apache::URI;
use NetSoup::Files::Directory;
use constant DIRECTORY => NetSoup::Files::Directory->new();
@NetSoup::Apache::Framework::Widgets::Tree::ISA = qw( NetSoup::Apache );
1;


sub widget {
  my $Tree   = shift;
  my $r      = shift;
  my $Node   = shift;
  my $subr   = $r->lookup_uri( $Node->getAttribute( Name => "path" ) );
  my $prune  = $Node->getAttribute( Name => "prune" );
  my $string = "<ul>" . $Tree->scan( $r, $subr->filename(), $prune ) . "</ul>\n";
  return( $string );
}


sub scan {
  my $Tree   = shift;
  my $r      = shift;
  my $path   = shift;
  my $prune  = shift;
  my $string = "";
  if ( -d $path ) {
    return( $string ) if( $path =~ m/^\./ );  # Exclude dot files
    $string .= qq(<li><strong>) . DIRECTORY->filename( Pathname => $path ) . "</strong><ul>\n";
    DIRECTORY->descend( Pathname    => $path,
                        Sort        => 1,
                        Recursive   => 0,
                        Files       => 1,
                        Directories => 1,
                        Callback    => sub {
                          my $pathname = shift;
                          my $filename = DIRECTORY->filename( Pathname => $pathname );
                          return(1) if( $filename =~ m/^\./ );  # Exclude dot files
                          if ( -d $pathname ) {
                            $string .= $Tree->scan( $r, $pathname );
                          } else {
                            my $url = $pathname;
                            $url    =~ s/^\Q$prune\E//;
                            $url      =~ s/[ ]/\%20/g;
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
                            $string .= qq(<li><a href="$url" target="_blank">$filename</a> ($fsize MB)</li>\n);
                          }
                        } );
    $string .= "</ul></li>\n";
  }
  return( $string );
}
