#!/usr/local/bin/perl -w

package NetSoup::Apache::Logging::FIFO;
use strict;
use Apache::Constants;
@NetSoup::Apache::Logging::FIFO::ISA = qw();
1;


sub logging {
  my $r      = shift;
  my $Logger = $r->dir_config( "LOGFILE" );
  my $ip     = $r->connection()->remote_ip();
  $r->warn( $Logger );
  if( -e $Logger ) {
    open( FIFO, "> $Logger" );
    print( FIFO "$ip\n" );
    close( FIFO );
  } else {
    $r->warn( "FIFO Not Found" );
  }
  return( OK );
}
