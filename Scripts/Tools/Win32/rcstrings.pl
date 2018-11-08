#!/usr/local/bin/perl
use NetSoup::Files::Directory;
my $files = NetSoup::Files::Directory->new();
foreach my $pathname ( @ARGV ) {
  $files->debug( $pathname );
  my $callback = sub {
    my $filename = shift;
    return(1) if( $filename !~ m/\.rc$/i );
    $files->debug( $filename );
    if( open( FILE, $filename ) ) {
      open( QUOTES, ">$filename~" );
      my $line = "";
      while( $line = <FILE> ) {
        while( $line =~ m/(\"[^\"]+\")/g ) {
          my $string = $1;
          if( $string ) {
            print( "$string\n" );
            print( QUOTES "$string\n" );
          }
        }
      }
      close( QUOTES );
      close( FILE );
    } else {
      $files->debug( "Error\t$filename" );
    }
    return(1);
  };
  $files->descend( Pathname    => $pathname,
                   Recursive   => 1,
                   Directories => 0,
                   Callback    => $callback );
}
exit(0);
