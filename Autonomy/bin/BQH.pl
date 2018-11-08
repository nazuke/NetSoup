#!/usr/local/bin/perl -w


use strict;
use POSIX;
use NetSoup::Protocol;
use NetSoup::Autonomy::DRE::Query::Burst;


if( fork ) {        # Spawn new process...
   exit(0);          # ...and exit parent
} else {
   chdir( "/" );
   close( STDIN );
  close( STDOUT );
  close( STDERR );
  POSIX::setsid();  #
  run();            # Execute server loop
}
exit(0);


sub run {
  my %args     = @_;             # Get arguments
  my $Protocol = NetSoup::Protocol->new();
  if( $Protocol->server( Port => 8000 ) ) {
    my $QUIT = 0;
    print( STDERR "BQH Ready\n" );
    $Protocol->loop( Args     => {},
                      Fork     => 0,
                      Quit     => \$QUIT,
                      Callback => sub {
                       request( Protocol => $Protocol );
                     } );
  } else {
    print( STDERR "BQH Initialisation Failed\n" );
  }
  return(1);
}


sub request {
  return(1);
}
