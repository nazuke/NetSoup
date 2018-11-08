#!/usr/local/bin/perl
#
#   NetSoup::Packages::GlotD::glotd.pl v00.00.01a 12042000
#
#   Copyright (C) 2000  Jason Holland <jason.holland@dial.pipex.com>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#
#   Description: This Perl 5.0 application is a forking Internet server
#                implementing the NetSoup GTP (Glossary Translation Protocol)
#                network protocol.


use strict;
use POSIX;
use NetSoup::Protocol;
use NetSoup::Protocol::GTP::Server;


$main::size    = -s $0;                           # Stores size of this script
$main::quit    = 0;                               # Set to true to quit by signal handler
$main::restart = 0;                               # Set to true to force a server restart
my $eCode      = 0;                               # Holds exit code of server
if( fork ) {                                      # Spawn new process...
   exit();                                         # ...and exit parent
} else {
   chdir( "/" );
   close( STDIN );
  close( STDOUT );
  close( STDERR );
  POSIX::setsid();
  %SIG = ( TERM => sub { $main::quit = 1 },       # Install signal handlers
           HUP  => sub { $main::quit    = 1;
                         $main::restart = 1 } );
  server() || exit(-1);                           # Begin server loop
  $eCode = quit();
  $eCode = reload() if( $main::restart );
}
exit( $eCode );


sub server {
  # This function is the main server loop.
  # Calls:
  #    none
  # Parameters Required:
  #    socket
  # Result Returned:
  #    boolean
  my $server = NetSoup::Protocol->new();                     # Get new socket protocol object
  my $port   = $server->getConfig( Key => "GlotServPort" );  # Obtain port number configuration
  if( $server->server( Port => $port ) ) {                   # Configure socket as server
    $server->loop( Callback => sub { service( $server ) },   # Enter main server loop
                   Args     => {},
                   Fork     => 1,
                   Quit     => \$main::quit );
  } else {
    return(0);
  }
  return(1);
}


sub service {
  # This function services an incoming client request.
  # Calls:
  #    none
  # Parameters Required:
  #    socket
  # Result Returned:
  #    boolean
  my $socket = shift;                                  # Get server object
  my $server = NetSoup::Protocol::GTP::Server->new();  # Get new glossary object
  $server->debug( "Servicing Request..." );            # DEBUG
  $server->request( Socket => $socket );               # Service client request
  return(1);
}


sub quit {
  # this function is invoked at server shutdown time.
  return(1);
}


sub reload {
  # This function forces a re-exec of the program.
  if( $main::size != -s $0 ) {  # Check size of script file
  } else {
    exec( $0 );                 # Exec into a new process
  }
  return(-1);
}
