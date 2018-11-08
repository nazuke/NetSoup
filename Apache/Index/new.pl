#!/usr/local/bin/perl -w

use NetSoup::Files::Directory;

my $time      = time;
my $week      = 60 * 60 * 24 * 7;
my $Directory = NetSoup::Files::Directory->new();
$Directory->descend( Pathname    => ".",
                     Files       => 1,
                     Directories => 0,
                     Extensions  => [ "pdf" ],
                     Recursive   => 1,
                     Callback    => sub {
                       my $pathname = shift;
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
                       if( ( $time - $mtime ) <= $week ) {
                         print( "$mtime $pathname\n" );
                       }
                       return(1);
                     } );
exit(0);
